import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/status_chip.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../domain/entities/reco_exception.dart';
import '../domain/reconciliation_period_filter.dart';
import 'controllers/reco_list_controller.dart';
import '../domain/usecases/import_sap_grns.dart';
import 'controllers/import_history_controller.dart';
import 'reco_exception_detail_page.dart';
import 'reconciliation_security_view.dart';

import '../../warehouse/domain/models/warehouse_reconciliation.dart';
import '../../warehouse/presentation/controllers/warehouse_providers.dart';
import '../../warehouse/presentation/controllers/warehouse_reconciliation_list_controller.dart';
import '../../../core/ui/widgets/filter_bar.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';

class RecoPage extends ConsumerWidget {
  const RecoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    
    if (role == UserRole.gateSecurity) {
      return const ReconciliationSecurityView();
    }
    
    if (role.isAdminOrWarehouseManager) {
      return const _WarehouseReconciliationView();
    }
    
    return const _RecoOperationsView();
  }
}

class _RecoOperationsView extends ConsumerWidget {
  const _RecoOperationsView();
  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recoListControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    if (role == UserRole.gateSecurity) {
      return const ReconciliationSecurityView();
    }
    final canImport =
        role.isAdminOrWarehouseManager;
    final importHistory = ref.watch(importHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation Exceptions'),
        actions: [
          if (canImport)
            TextButton.icon(
              onPressed: () => _importSap(context, ref),
              icon: const Icon(Icons.upload_file),
              label: const Text('Import SAP GRNs'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(recoListControllerProvider.notifier).refresh(),
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: state.when(
        data: (exceptions) {
          if (exceptions.isEmpty) {
            return const Center(child: Text('No exceptions to reconcile!'));
          }

          final isMob = isMobile(context);

          return RefreshIndicator(
              onRefresh: () async =>
                  ref.read(recoListControllerProvider.notifier).refresh(),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionHeader(
                          title: 'Actionable Exceptions',
                          subtitle:
                              'Resolve discrepancies between Gate Entries and SAP GRNs.',
                          trailing: isMob
                              ? null
                              : Text('${exceptions.length} Items Pending',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)),
                        ),
                        if (importHistory.isNotEmpty)
                          _buildImportHistory(context, importHistory),
                        if (importHistory.isNotEmpty)
                          const SizedBox(height: 16),
                        Expanded(
                            child: isMob
                                ? _buildMobileList(exceptions, context, ref)
                                : _buildDesktopTable(exceptions, context, ref)),
                      ])));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final key = status.toLowerCase();
    if (key == 'resolved' || key == 'matched') {
      return const Color(0xFF16A34A); // Green
    }
    if (key.contains('quantity') && key.contains('mismatch')) {
      return const Color(0xFFF59E0B); // Amber
    }
    if (key.contains('pending') ||
        key.contains('not_posted') ||
        key.contains('missing')) {
      return Colors.grey;
    }
    return const Color(0xFFDC2626); // Red (Duplicate, Wrong PO)
  }

  IconData _getStatusIcon(String status) {
    final key = status.toLowerCase();
    if (key == 'resolved' || key == 'matched') {
      return Icons.check_circle;
    }
    if (key.contains('quantity') && key.contains('mismatch')) {
      return Icons.warning_amber_rounded;
    }
    if (key.contains('pending') ||
        key.contains('not_posted') ||
        key.contains('missing')) {
      return Icons.hourglass_empty;
    }
    return Icons.error_outline;
  }

  Future<_RecoImportOptions?> _showImportConfirmDialog(
      BuildContext context, String fileName) async {
    bool runRecon = true;
    _RecoImportMode mode = _RecoImportMode.singleDate;
    DateTime? selectedDate = DateTime.now();
    DateTime? rangeStart;
    DateTime? rangeEnd;
    return showDialog<_RecoImportOptions>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Confirm Import'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File: $fileName'),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Run Reconciliation'),
                subtitle: const Text('Sync with Gate Entries immediately'),
                value: runRecon,
                onChanged: (val) => setState(() => runRecon = val ?? false),
                contentPadding: EdgeInsets.zero,
              ),
              if (runRecon) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Single Date'),
                      selected: mode == _RecoImportMode.singleDate,
                      onSelected: (_) =>
                          setState(() => mode = _RecoImportMode.singleDate),
                    ),
                    ChoiceChip(
                      label: const Text('Date Range'),
                      selected: mode == _RecoImportMode.dateRange,
                      onSelected: (_) =>
                          setState(() => mode = _RecoImportMode.dateRange),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (mode == _RecoImportMode.singleDate)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? now,
                          firstDate: DateTime(now.year - 5),
                          lastDate: DateTime(now.year + 2),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      icon: const Icon(Icons.event_rounded, size: 18),
                      label: Text(
                        selectedDate == null
                            ? 'Select reconciliation date'
                            : _displayDateFormat.format(selectedDate!),
                      ),
                    ),
                  ),
                if (mode == _RecoImportMode.dateRange)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(now.year - 5),
                          lastDate: DateTime(now.year + 2),
                          initialDateRange:
                              rangeStart != null && rangeEnd != null
                                  ? DateTimeRange(
                                      start: rangeStart!,
                                      end: rangeEnd!,
                                    )
                                  : null,
                        );
                        if (picked != null) {
                          setState(() {
                            rangeStart = picked.start;
                            rangeEnd = picked.end;
                          });
                        }
                      },
                      icon: const Icon(Icons.date_range_rounded, size: 18),
                      label: Text(
                        rangeStart != null && rangeEnd != null
                            ? '${_displayDateFormat.format(rangeStart!)} - ${_displayDateFormat.format(rangeEnd!)}'
                            : 'Select reconciliation range',
                      ),
                    ),
                  ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: !runRecon ||
                      (mode == _RecoImportMode.singleDate &&
                          selectedDate != null) ||
                      (mode == _RecoImportMode.dateRange &&
                          rangeStart != null &&
                          rangeEnd != null)
                  ? () => Navigator.pop(
                        context,
                        _RecoImportOptions(
                          runReconciliation: runRecon,
                          date: runRecon && mode == _RecoImportMode.singleDate
                              ? selectedDate
                              : null,
                          rangeStart:
                              runRecon && mode == _RecoImportMode.dateRange
                                  ? rangeStart
                                  : null,
                          rangeEnd:
                              runRecon && mode == _RecoImportMode.dateRange
                                  ? rangeEnd
                                  : null,
                        ),
                      )
                  : null,
              child: const Text('Import'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importSap(BuildContext context, WidgetRef ref) async {
    final fileResult = await ref.read(importSapGrnsUseCaseProvider).pickFile();
    if (fileResult == null) return;

    if (!context.mounted) return;
    final importOptions =
        await _showImportConfirmDialog(context, fileResult.name);
    if (importOptions == null) return;

    final response = await ref
        .read(importSapGrnsUseCaseProvider)
        .execute(
          fileResult,
          runReconciliation: importOptions.runReconciliation,
          reconciliationDate: importOptions.date,
          reconciliationRangeStart: importOptions.rangeStart,
          reconciliationRangeEnd: importOptions.rangeEnd,
        );

    ref.read(importHistoryProvider.notifier).addItem(
          ImportHistoryItem(
            timestamp: DateTime.now(),
            fileName: fileResult.name,
            success: response.success,
            message: response.message.isNotEmpty
                ? response.message
                : (response.success ? 'Import completed' : 'Import failed'),
          ),
        );

    if (context.mounted) {
      if (response.success) {
        final result = response.data;
        final imported = result?.importedCount ?? result?.processed ?? 0;
        String msg = imported > 0 
           ? 'Successfully imported $imported records' 
           : 'Import completed';

        if (importOptions.runReconciliation) {
          if (result?.summary != null) {
            final matched = result!.summary!.gateEntries.matched;
            final total = result.summary!.gateEntries.total;
            msg = 'Imported $imported & Reconciled: $matched/$total Matched';
          } else {
            msg = 'Imported $imported records. Reconciliation is in progress.';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        await ref.read(recoListControllerProvider.notifier).refresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty
                ? response.message
                : 'Import failed'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<String?> _showResolveDialog(
      BuildContext context, RecoException exc) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Exception'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Resolution Notes',
            hintText: 'Provide resolution details',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
    return result != null && result.isNotEmpty ? result : null;
  }

  Widget _buildMobileList(
      List<RecoException> exceptions, BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final canResolve =
        role.isAdminOrWarehouseManager;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: exceptions.length,
      itemBuilder: (context, index) {
        final exc = exceptions[index];
        final color = _getStatusColor(exc.status);
        final icon = _getStatusIcon(exc.status);

        return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecoExceptionDetailPage(exceptionId: exc.id),
                ),
              );
            },
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.5)),
              ),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Gate Entry No: ${exc.gateEntryId}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        StatusChip(label: exc.status, color: color, icon: icon),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Matched GRN: ${exc.poNumber}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(exc.description,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            DateFormat('MMM dd, yyyy - hh:mm a')
                                .format(exc.createdAt),
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: color,
                            side: BorderSide(color: color),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                          ),
                          onPressed: () async {
                            if (!canResolve) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Access Denied. Mgr required.')));
                              return;
                            }
                            final notes =
                                await _showResolveDialog(context, exc);
                            if (notes == null) return;
                            await ref
                                .read(recoListControllerProvider.notifier)
                                .resolveException(exc.id, notes);
                          },
                          child: const Text('Resolve'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  Widget _buildDesktopTable(
      List<RecoException> exceptions, BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final canResolve =
        role.isAdminOrWarehouseManager;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 24,
          minWidth: 1000,
          headingRowHeight: 56,
          dataRowHeight: 68,
          columns: const [
            DataColumn2(label: Text('Status'), size: ColumnSize.L),
            DataColumn2(label: Text('Gate Entry'), size: ColumnSize.S),
            DataColumn2(label: Text('Matched GRN'), size: ColumnSize.M),
            DataColumn2(label: Text('Description'), size: ColumnSize.L),
            DataColumn2(label: Text('Reconciled At'), size: ColumnSize.M),
            DataColumn2(label: Text('Action'), size: ColumnSize.S),
          ],
          rows: exceptions.map((RecoException exc) {
            final color = _getStatusColor(exc.status);
            final icon = _getStatusIcon(exc.status);
            return DataRow(
              onSelectChanged: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        RecoExceptionDetailPage(exceptionId: exc.id),
                  ),
                );
              },
              cells: [
                DataCell(
                    StatusChip(label: exc.status, color: color, icon: icon)),
                DataCell(Text(exc.gateEntryId,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(exc.poNumber)),
                DataCell(Text(exc.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis)),
                DataCell(Text(DateFormat('MMM dd, yyyy - hh:mm a')
                    .format(exc.createdAt))),
                DataCell(FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () async {
                    if (!canResolve) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Access Denied. Mgr Required.')));
                      return;
                    }
                    final notes = await _showResolveDialog(context, exc);
                    if (notes == null) return;
                    await ref
                        .read(recoListControllerProvider.notifier)
                        .resolveException(exc.id, notes);
                  },
                  child: const Text('Resolve'),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildImportHistory(
      BuildContext context, List<ImportHistoryItem> history) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import History',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...history.take(5).map((item) {
              final time =
                  DateFormat('MMM dd, yyyy - hh:mm a').format(item.timestamp);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  item.success ? Icons.check_circle : Icons.error,
                  color: item.success ? Colors.green : Colors.redAccent,
                ),
                title: Text(item.fileName),
                subtitle: Text('$time - ${item.message}'),
              );
            }),
          ],
        ),
      ),
    );
  }
}

enum _RecoImportMode { singleDate, dateRange }

class _RecoImportOptions {
  const _RecoImportOptions({
    required this.runReconciliation,
    this.date,
    this.rangeStart,
    this.rangeEnd,
  });

  final bool runReconciliation;
  final DateTime? date;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
}



// ---------------------------------------------------------------------------
// WAREHOUSE RECO VIEW (merged from warehouse_reconciliation_list_page.dart)
// ---------------------------------------------------------------------------

class _WarehouseReconciliationView extends ConsumerStatefulWidget {
  const _WarehouseReconciliationView();

  @override
  ConsumerState<_WarehouseReconciliationView> createState() =>
      __WarehouseReconciliationViewState();
}

class __WarehouseReconciliationViewState
    extends ConsumerState<_WarehouseReconciliationView> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  ReconciliationPeriodFilter _periodFilter = ReconciliationPeriodFilter.all;
  bool _hasExplicitPeriodSelection = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final isManager =
        role == UserRole.warehouseManager || role == UserRole.whMgr || role == UserRole.admin;
    final state = ref.watch(warehouseReconciliationListControllerProvider);
    final isMob = isMobile(context);
    final isTab = isTablet(context);

    if (!isManager) {
      return const Scaffold(
        body: Center(child: Text('Manager/Admin access required.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref
                  .read(warehouseReconciliationListControllerProvider.notifier)
                  .refresh(filter: _periodFilter);
              ref.invalidate(warehouseManagerDashboardSummaryProvider);
            },
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading && state.items.isEmpty
          ? _buildLoadingView(isMob, isTab)
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(warehouseReconciliationListControllerProvider.notifier)
                    .refresh(filter: _periodFilter);
                ref.invalidate(warehouseManagerDashboardSummaryProvider);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = constraints.maxWidth > 1440
                      ? 1440.0
                      : constraints.maxWidth;
                  final filtered = _applyFilters(state.items);

                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: contentWidth,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMob ? 16 : 24,
                          vertical: isMob ? 16 : 24,
                        ),
                        children: [
                          _buildSummarySection(context, filtered, state.items, isMob, isTab),
                          const SizedBox(height: 16),
                          _buildFilters(context, filtered.length, isMob),
                          const SizedBox(height: 16),
                          if (state.error != null) ...[
                            _buildErrorBanner(context, state.error!),
                            const SizedBox(height: 16),
                          ],
                          filtered.isEmpty
                              ? _buildEmptyState(context)
                              : isMob
                                  ? _buildMobileList(context, filtered)
                                  : _buildDesktopTable(context, filtered, isTab),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  List<WarehouseReconciliationRecord> _applyFilters(
    List<WarehouseReconciliationRecord> items,
  ) {
    final query = _searchQuery.trim().toLowerCase();

    return items.where((item) {
      final matchesSearch = query.isEmpty ||
          item.gateEntryId.toLowerCase().contains(query) ||
          item.gateEntryNo.toLowerCase().contains(query) ||
          item.displayReason.toLowerCase().contains(query) ||
          item.reasonCode.toLowerCase().contains(query) ||
          item.matchedGrnNumber.toLowerCase().contains(query) ||
          item.displayStatus.toLowerCase().contains(query);
      final matchesStatus = switch (_statusFilter) {
        'Matched' => item.isMatched,
        'Exception' => item.isException,
        'Resolved' => item.isResolved,
        'Open' => !item.isResolved,
        _ => true,
      };

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Widget _buildSummarySection(
    BuildContext context,
    List<WarehouseReconciliationRecord> filtered,
    List<WarehouseReconciliationRecord> all,
    bool isMob,
    bool isTab,
  ) {
    final matched = filtered.where((e) => e.isMatched).length;
    final exceptions = filtered.where((e) => e.isException).length;
    final resolved = filtered.where((e) => e.isResolved).length;
    final open = all.where((e) => !e.isResolved).length;

    final cards = [
      _summaryCard(
        context,
        title: 'Matched',
        value: '$matched',
        subtitle: 'No issue',
        icon: Icons.check_circle,
        accent: Colors.green,
      ),
      _summaryCard(
        context,
        title: 'Exceptions',
        value: '$exceptions',
        subtitle: 'Need review',
        icon: Icons.error_outline,
        accent: Colors.red,
      ),
      _summaryCard(
        context,
        title: 'Resolved',
        value: '$resolved',
        subtitle: 'Issue closed',
        icon: Icons.verified,
        accent: Colors.blue,
      ),
      _summaryCard(
        context,
        title: 'Open',
        value: '$open',
        subtitle: 'Needs resolution',
        icon: Icons.pending_actions,
        accent: Colors.orange,
      ),
    ];

    if (isMob) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 10),
          Expanded(child: cards[1]),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        SizedBox(width: isTab ? 10 : 12),
        Expanded(child: cards[1]),
        SizedBox(width: isTab ? 10 : 12),
        Expanded(child: cards[2]),
        SizedBox(width: isTab ? 10 : 12),
        Expanded(child: cards[3]),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, int count, bool isMob) {
    return FilterBar(
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count records',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final period in ReconciliationPeriodFilter.values)
              ChoiceChip(
                label: Text(period.label),
                selected:
                    _hasExplicitPeriodSelection && _periodFilter == period,
                onSelected: (_) async {
                  if (_hasExplicitPeriodSelection && _periodFilter == period) {
                    return;
                  }
                  setState(() {
                    _periodFilter = period;
                    _hasExplicitPeriodSelection = true;
                  });
                  await ref
                      .read(warehouseReconciliationListControllerProvider.notifier)
                      .refresh(filter: period);
                  ref.invalidate(warehouseManagerDashboardSummaryProvider);
                },
              ),
          ],
        ),
        SizedBox(
          width: isMob ? double.infinity : 320,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search gate entry no, reason, GRN, status',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        SizedBox(
          width: isMob ? double.infinity : 220,
          child: DropdownButtonFormField<String>(
            initialValue: _statusFilter,
            decoration: InputDecoration(
              labelText: 'Filter',
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Matched', child: Text('Matched')),
              DropdownMenuItem(value: 'Exception', child: Text('Exception')),
              DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
              DropdownMenuItem(value: 'Open', child: Text('Open')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _statusFilter = val);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView(bool isMob, bool isTab) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? 16 : 24,
        vertical: isMob ? 16 : 24,
      ),
      children: [
        const SkeletonLoader(width: double.infinity, height: 150),
        const SizedBox(height: 16),
        if (isMob)
          const SkeletonLoader(width: double.infinity, height: 88)
        else
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 82 : 92,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 82 : 92,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 82 : 92,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 82 : 92,
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        const SkeletonLoader(width: double.infinity, height: 88),
        const SizedBox(height: 16),
        const SkeletonLoader(width: double.infinity, height: 420),
      ],
    );
  }

  Widget _buildMobileList(
    BuildContext context,
    List<WarehouseReconciliationRecord> items,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final color = _statusColor(item);
        return InkWell(
          onTap: () => _openDetail(context, item),
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: color.withValues(alpha: 0.4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.gateEntryNo.isEmpty ? item.id : item.gateEntryNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      _statusChip(item),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.displayReason.isEmpty ? 'Reason: -' : 'Reason: ${item.displayReason}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Matched GRN: ${item.matchedGrnNumber.isEmpty ? '-' : item.matchedGrnNumber}',
                  ),
                  const SizedBox(height: 6),
                  Text('Qty Variance: ${item.qtyVariance}'),
                  const SizedBox(height: 6),
                  Text(
                    'Date: ${item.date != null ? DateFormat('MMM dd, yyyy - hh:mm a').format(item.date!) : 'N/A'}',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<WarehouseReconciliationRecord> items,
    bool isTab,
  ) {
    return SizedBox(
      height: 560,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: DataTable2(
            columnSpacing: isTab ? 10 : 14,
            horizontalMargin: isTab ? 16 : 24,
            minWidth: 1260,
            headingRowHeight: 60,
            dataRowHeight: 68,
            showCheckboxColumn: false,
            columns: const [
              DataColumn2(label: Text('Gate Entry No'), size: ColumnSize.M),
              DataColumn2(label: Text('Status'), size: ColumnSize.S),
              DataColumn2(label: Text('Reason'), size: ColumnSize.L),
              DataColumn2(label: Text('Qty Variance'), size: ColumnSize.S),
              DataColumn2(label: Text('Matched GRN'), size: ColumnSize.M),
              DataColumn2(label: Text('Date'), size: ColumnSize.M),
              DataColumn2(label: Text('Resolution'), size: ColumnSize.M),
            ],
            rows: items.map((item) {
              return DataRow(
                onSelectChanged: (_) => _openDetail(context, item),
                cells: [
                  DataCell(Text(
                    item.gateEntryNo.isEmpty ? item.id : item.gateEntryNo,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  )),
                  DataCell(_statusChip(item)),
                  DataCell(SizedBox(
                    width: 280,
                    child: Text(
                      item.displayReason.isEmpty ? '-' : item.displayReason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                  DataCell(Text(item.qtyVariance.toString())),
                  DataCell(Text(
                    item.matchedGrnNumber.isEmpty ? '-' : item.matchedGrnNumber,
                  )),
                  DataCell(Text(
                    item.date != null
                        ? DateFormat('MMM dd, yyyy - hh:mm a').format(item.date!)
                        : 'N/A',
                  )),
                  DataCell(Text(item.isResolved ? 'Resolved' : 'Open')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rule_folder_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No reconciliations found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try changing search text or filter to see more records.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(WarehouseReconciliationRecord item) {
    final label = _statusLabel(item);
    final color = _statusColor(item);
    return StatusChip(label: label, color: color);
  }

  String _statusLabel(WarehouseReconciliationRecord item) {
    return item.displayStatus;
  }

  Color _statusColor(WarehouseReconciliationRecord item) {
    final key = item.normalizedStatus;
    if (item.isMatched) return Colors.green;
    if (key == 'quantity_mismatch') return Colors.orange;
    if (key == 'pending_grn' || key == 'grn_not_posted') return Colors.red;
    if (key == 'duplicate_grn') return Colors.deepOrange;
    if (key == 'wrong_po_material') return Colors.indigo;
    if (item.isResolved) return Colors.blue;
    if (item.isException) return Colors.red;
    return Colors.grey;
  }

  Widget _buildErrorBanner(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        error,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }

  void _openDetail(BuildContext context, WarehouseReconciliationRecord item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecoExceptionDetailPage(record: item),
      ),
    );
  }
}
