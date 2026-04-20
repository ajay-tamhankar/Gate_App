import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/grn_upload_state.dart';
import '../controllers/grn_upload_provider.dart';

/// Material 3 card for importing GRN CSV/XLSX data.
class GrnImportCard extends ConsumerStatefulWidget {
  const GrnImportCard({super.key});

  @override
  ConsumerState<GrnImportCard> createState() => _GrnImportCardState();
}

class _GrnImportCardState extends ConsumerState<GrnImportCard> {
  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  ProviderSubscription<GrnUploadState>? _uploadSubscription;

  @override
  void initState() {
    super.initState();
    _uploadSubscription = ref.listenManual<GrnUploadState>(
      grnUploadProvider,
      (previous, next) {
        if (!mounted) return;

        if (next is GrnUploadSuccess) {
          _showSnackbar(
            context,
            next.message,
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.onPrimaryContainer,
          );
          Future.microtask(
            () => ref.read(grnUploadProvider.notifier).reset(),
          );
        } else if (next is GrnUploadError) {
          _showSnackbar(
            context,
            next.message,
            Theme.of(context).colorScheme.errorContainer,
            Theme.of(context).colorScheme.onErrorContainer,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _uploadSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const allowedFileLabel = 'CSV/XLSX';
    const uploadDescription = kIsWeb
        ? 'Upload a CSV or XLSX file exported from SAP. If you want instant reconciliation, choose the GRN date window before upload.'
        : 'Upload a CSV or XLSX file exported from SAP, then optionally reconcile it against gate entries for a specific date window.';

    final uploadState = ref.watch(grnUploadProvider);
    final notifier = ref.read(grnUploadProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isLoading = uploadState is GrnUploadLoading;
    final selectedFile = switch (uploadState) {
      GrnUploadFileSelected(:final file) => file,
      GrnUploadLoading(:final file) => file,
      _ => null,
    };
    final uploadMode = switch (uploadState) {
      GrnUploadFileSelected(:final mode) => mode,
      GrnUploadLoading(:final mode) => mode,
      _ => GrnUploadMode.importOnly,
    };
    final selectedDate = switch (uploadState) {
      GrnUploadFileSelected(:final selectedDate) => selectedDate,
      GrnUploadLoading(:final selectedDate) => selectedDate,
      _ => null,
    };
    final rangeStart = switch (uploadState) {
      GrnUploadFileSelected(:final rangeStart) => rangeStart,
      GrnUploadLoading(:final rangeStart) => rangeStart,
      _ => null,
    };
    final rangeEnd = switch (uploadState) {
      GrnUploadFileSelected(:final rangeEnd) => rangeEnd,
      GrnUploadLoading(:final rangeEnd) => rangeEnd,
      _ => null,
    };
    final hasFile = selectedFile != null;
    final canUpload =
        hasFile && !isLoading && _isUploadReady(uploadMode, selectedDate, rangeStart, rangeEnd);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      color: colorScheme.primaryContainer.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.cloud_upload_rounded,
                    color: colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import GRN Data',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        uploadDescription,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: isLoading ? null : notifier.pickFile,
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: const Text('Choose $allowedFileLabel File'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (hasFile)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.secondaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insert_drive_file_rounded,
                          size: 16,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            selectedFile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (hasFile)
                  SizedBox(
                    width: double.infinity,
                    child: _buildReconciliationPanel(
                      context,
                      notifier,
                      uploadMode: uploadMode,
                      selectedDate: selectedDate,
                      rangeStart: rangeStart,
                      rangeEnd: rangeEnd,
                      isLoading: isLoading,
                    ),
                  ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: canUpload ? notifier.upload : null,
                  icon: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.upload_rounded, size: 18),
                  label: Text(isLoading ? 'Uploading...' : 'Upload'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                kIsWeb
                    ? 'Preparing file and uploading. This can take a few seconds on web...'
                    : 'Uploading file, please wait...',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSnackbar(
    BuildContext context,
    String message,
    Color background,
    Color foreground,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  Widget _buildReconciliationPanel(
    BuildContext context,
    GrnUploadNotifier notifier, {
    required GrnUploadMode uploadMode,
    required DateTime? selectedDate,
    required DateTime? rangeStart,
    required DateTime? rangeEnd,
    required bool isLoading,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reconciliation window',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose whether to import only or reconcile gate entries for one day or a date range.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Import Only'),
                selected: uploadMode == GrnUploadMode.importOnly,
                onSelected: isLoading
                    ? null
                    : (_) => notifier.setUploadMode(GrnUploadMode.importOnly),
              ),
              ChoiceChip(
                label: const Text('Single Date'),
                selected: uploadMode == GrnUploadMode.singleDate,
                onSelected: isLoading
                    ? null
                    : (_) => notifier.setUploadMode(GrnUploadMode.singleDate),
              ),
              ChoiceChip(
                label: const Text('Date Range'),
                selected: uploadMode == GrnUploadMode.dateRange,
                onSelected: isLoading
                    ? null
                    : (_) => notifier.setUploadMode(GrnUploadMode.dateRange),
              ),
            ],
          ),
          if (uploadMode == GrnUploadMode.singleDate) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => _selectSingleDate(context, notifier, selectedDate),
              icon: const Icon(Icons.event_rounded, size: 18),
              label: Text(
                selectedDate == null
                    ? 'Select GRN date'
                    : _displayDateFormat.format(selectedDate),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Only gate entries from the selected day will be compared after import.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (uploadMode == GrnUploadMode.dateRange) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => _selectDateRange(context, notifier, rangeStart, rangeEnd),
              icon: const Icon(Icons.date_range_rounded, size: 18),
              label: Text(
                rangeStart != null && rangeEnd != null
                    ? '${_displayDateFormat.format(rangeStart)} - ${_displayDateFormat.format(rangeEnd)}'
                    : 'Select GRN date range',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gate entries inside the selected range will be included in reconciliation.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectSingleDate(
    BuildContext context,
    GrnUploadNotifier notifier,
    DateTime? initialDate,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      notifier.setSingleDate(picked);
    }
  }

  Future<void> _selectDateRange(
    BuildContext context,
    GrnUploadNotifier notifier,
    DateTime? rangeStart,
    DateTime? rangeEnd,
  ) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
      initialDateRange: rangeStart != null && rangeEnd != null
          ? DateTimeRange(start: rangeStart, end: rangeEnd)
          : null,
    );
    if (picked != null) {
      notifier.setDateRange(picked.start, picked.end);
    }
  }

  bool _isUploadReady(
    GrnUploadMode mode,
    DateTime? selectedDate,
    DateTime? rangeStart,
    DateTime? rangeEnd,
  ) {
    switch (mode) {
      case GrnUploadMode.importOnly:
        return true;
      case GrnUploadMode.singleDate:
        return selectedDate != null;
      case GrnUploadMode.dateRange:
        return rangeStart != null && rangeEnd != null;
    }
  }
}
