import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/ui/widgets/loading_overlay.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import 'controllers/reco_exception_detail_controller.dart';
import '../domain/entities/reco_exception.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/widgets/logout_action.dart';
import 'controllers/reco_list_controller.dart';

import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/status_chip.dart';
import '../../warehouse/domain/models/warehouse_gate_entry.dart';
import '../../warehouse/domain/models/warehouse_reconciliation.dart';
import '../../warehouse/presentation/controllers/warehouse_providers.dart';

class RecoExceptionDetailPage extends ConsumerWidget {
  final String? exceptionId;
  final WarehouseReconciliationRecord? record;

  const RecoExceptionDetailPage({super.key, this.exceptionId, this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    
    if (role.isAdminOrWarehouseManager) {
      if (record == null) return const Scaffold(body: Center(child: Text('Record required for Admin/Manager view')));
      return _WarehouseReconciliationDetailView(record: record!);
    }
    
    if (exceptionId == null) return const Scaffold(body: Center(child: Text('Exception ID required for Security view')));
    return _RecoExceptionDetailSecurityView(exceptionId: exceptionId!);
  }
}

class _RecoExceptionDetailSecurityView extends ConsumerWidget {
  final String exceptionId;

  const _RecoExceptionDetailSecurityView({required this.exceptionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(recoExceptionDetailProvider(exceptionId));
    final isResolving = ref.watch(recoListControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exception Details'),
        actions: const [
          LogoutAction(),
          SizedBox(width: 8),
        ],
      ),
      body: LoadingOverlay(
        isLoading: isResolving,
        message: 'Resolving exception...',
        child: detailAsync.when(
          data: (exception) => _buildContent(context, ref, exception),
          loading: () => ListView(
            padding: const EdgeInsets.all(24),
            children: const [
              SkeletonLoader(width: 200, height: 28),
              SizedBox(height: 16),
              SkeletonLoader(width: double.infinity, height: 180),
            ],
          ),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, RecoException exc) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final canResolve =
        role.isAdminOrWarehouseManager;

    final createdAt =
        DateFormat('MMM dd, yyyy - hh:mm a').format(exc.createdAt.toLocal());
    final parsedResolvedAt = DateTime.tryParse(exc.resolvedAt ?? '');
    final resolvedAt = parsedResolvedAt != null
        ? DateFormat('MMM dd, yyyy - hh:mm a').format(parsedResolvedAt.toLocal())
        : 'Not resolved';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SectionHeader(
          title: 'Exception ${exc.id}',
          subtitle: 'Gate Entry No: ${exc.gateEntryId}',
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Status', exc.status),
                const SizedBox(height: 12),
                _infoRow('Matched GRN', exc.poNumber),
                const SizedBox(height: 12),
                _infoRow('Reconciled At', createdAt),
                const SizedBox(height: 12),
                _infoRow('Resolved At', resolvedAt),
                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(exc.description),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (canResolve && parsedResolvedAt == null)
          FilledButton.icon(
            onPressed: () async {
              final notes = await _showResolveDialog(context);
              if (notes == null) return;
              await ref
                  .read(recoListControllerProvider.notifier)
                  .resolveException(exc.id, notes);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Exception resolved'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Resolve Exception'),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  Future<String?> _showResolveDialog(BuildContext context) async {
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
}



// ---------------------------------------------------------------------------
// WAREHOUSE RECO DETAIL VIEW (merged from warehouse_reconciliation_detail_page.dart)
// ---------------------------------------------------------------------------

class _WarehouseReconciliationDetailView extends ConsumerWidget {
  final WarehouseReconciliationRecord record;

  const _WarehouseReconciliationDetailView({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Orphan / pending-grn synthetic rows may not have a gateEntryId; the
    // detail provider expects a non-null id, so fall back to an empty string
    // and surface a friendlier error below.
    final detail = ref.watch(
      warehouseGateEntryDetailProvider(record.gateEntryId ?? ''),
    );
    final isMob = isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation Detail'),
        actions: const [
          LogoutAction(),
          SizedBox(width: 8),
        ],
      ),
      body: detail.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            SkeletonLoader(width: 220, height: 32),
            SizedBox(height: 16),
            SkeletonLoader(width: double.infinity, height: 160),
            SizedBox(height: 24),
            SkeletonLoader(width: double.infinity, height: 260),
          ],
        ),
        error: (e, _) => Center(child: Text('Failed to load details: $e')),
        data: (entry) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SectionHeader(
                title: (record.gateEntryNo?.isNotEmpty == true)
                    ? record.gateEntryNo!
                    : entry.gateEntryNo,
                subtitle:
                    'Status: ${record.displayStatus} | ${record.date != null ? DateFormat('MMM dd, yyyy - hh:mm a').format(record.date!) : 'No date'}',
                trailing: _statusChip(record),
              ),
              // Everything captured by gate security at entry-creation time.
              // Reconciliation reviewers need the full picture to judge the
              // exception, so render every field the backend gave us.
              _sectionCard(
                context,
                title: 'Gate Entry — All Captured Fields',
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _infoBlock(
                      context,
                      'Gate Entry No',
                      entry.gateEntryNo,
                      isMob,
                    ),
                    _infoBlock(
                      context,
                      'Direction',
                      _humanizeMovement(entry.gateMovement),
                      isMob,
                    ),
                    _infoBlock(
                      context,
                      'Challan No',
                      entry.challanNo,
                      isMob,
                    ),
                    _infoBlock(
                      context,
                      'Document Date',
                      entry.documentDate != null
                          ? DateFormat('MMM dd, yyyy')
                              .format(entry.documentDate!.toLocal())
                          : '',
                      isMob,
                    ),
                    _infoBlock(
                      context,
                      'Entry Time',
                      entry.entryTime != null
                          ? DateFormat('MMM dd, yyyy - hh:mm a')
                              .format(entry.entryTime!.toLocal())
                          : '',
                      isMob,
                    ),
                    _infoBlock(
                      context,
                      'Gate Out Time',
                      entry.gateOutTimestamp != null
                          ? DateFormat('MMM dd, yyyy - hh:mm a')
                              .format(entry.gateOutTimestamp!.toLocal())
                          : '',
                      isMob,
                    ),
                    _infoBlock(context, 'Vendor Name', entry.vendorName, isMob),
                    _infoBlock(context, 'Vendor Code', entry.vendorCode, isMob),
                    _infoBlock(context, 'PO Number', entry.poNumber, isMob),
                    _infoBlock(context, 'Vehicle No', entry.vehicleNo, isMob),
                    _infoBlock(context, 'LR Number', entry.lrNumber, isMob),
                    _infoBlock(
                      context,
                      'Transporter',
                      entry.transporterName,
                      isMob,
                    ),
                    _infoBlock(
                      context,
                      'Driver Contact',
                      entry.driverContactNo,
                      isMob,
                    ),
                    _infoBlock(
                      context,
                      'Workflow Status',
                      entry.statusLabel,
                      isMob,
                    ),
                    _infoBlock(
                      context,
                      'Verified',
                      entry.isVerified ? 'Yes' : 'No',
                      isMob,
                    ),
                    if (entry.remarks.isNotEmpty)
                      _infoBlock(context, 'Remarks', entry.remarks, isMob),
                    if (entry.createdBy != null && entry.createdBy!.isNotEmpty)
                      _infoBlock(
                          context, 'Created By', entry.createdBy!, isMob),
                    if (entry.verifiedBy != null &&
                        entry.verifiedBy!.isNotEmpty)
                      _infoBlock(
                          context, 'Verified By', entry.verifiedBy!, isMob),
                    if (entry.approvedBy != null &&
                        entry.approvedBy!.isNotEmpty)
                      _infoBlock(
                          context, 'Approved By', entry.approvedBy!, isMob),
                    if (entry.gateOutBy != null && entry.gateOutBy!.isNotEmpty)
                      _infoBlock(
                          context, 'Gate Out By', entry.gateOutBy!, isMob),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Items captured per challan line — each row is what gate
              // security typed against a specific PO line.
              if (entry.items.isNotEmpty) ...[
                _sectionCard(
                  context,
                  title: 'Challan Items (${entry.items.length})',
                  child: _GateEntryItemsTable(items: entry.items),
                ),
                const SizedBox(height: 16),
              ],
              _sectionCard(
                context,
                title: 'Reconciliation Result',
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _infoBlock(context, 'Status', record.displayStatus, isMob),
                    _infoBlock(
                      context,
                      'Matched GRN',
                      record.matchedGrnNumber.isEmpty ? '-' : record.matchedGrnNumber,
                      isMob,
                    ),
                    _infoBlock(
                      context,
                      'GRN Posting Date',
                      record.grnPostingDate != null
                          ? DateFormat('MMM dd, yyyy')
                              .format(record.grnPostingDate!.toLocal())
                          : '-',
                      isMob,
                    ),
                    _highlightBlock(
                      context,
                      'Qty Variance',
                      '${record.qtyVariance}',
                      isMob,
                      record.isException,
                    ),
                    _infoBlock(
                      context,
                      'Reason Code',
                      record.reasonCode.isEmpty ? '-' : record.reasonCode,
                      isMob,
                    ),
                    _infoBlock(
                      context,
                      'Reason',
                      record.displayReason.isEmpty ? '-' : record.displayReason,
                      isMob,
                    ),
                    _infoBlock(
                      context,
                      'Resolution Notes',
                      record.resolutionNotes.isEmpty ? '-' : record.resolutionNotes,
                      isMob,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildComparisonSection(context, entry),
              _sectionCard(
                context,
                title: 'Attachments',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (entry.attachments.isEmpty)
                      Text(
                        'No attachments available.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ...entry.attachments.map(
                      (attachment) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(attachment.fileName),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                context,
                title: 'Status Section',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statusChip(record),
                    if (record.displayReason.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Reason: ${record.displayReason}'),
                    ],
                    if (record.resolutionNotes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Resolution: ${record.resolutionNotes}'),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoBlock(
    BuildContext context,
    String label,
    String value,
    bool isMob,
  ) {
    return Container(
      width: isMob ? double.infinity : 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(value.isEmpty ? 'N/A' : value),
        ],
      ),
    );
  }

  Widget _highlightBlock(
    BuildContext context,
    String label,
    String value,
    bool isMob,
    bool highlight,
  ) {
    return Container(
      width: isMob ? double.infinity : 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.red.withValues(alpha: 0.08)
            : Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? Colors.red.withValues(alpha: 0.35)
              : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(value),
        ],
      ),
    );
  }

  String _humanizeMovement(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final normalized = trimmed.toLowerCase();
    if (normalized.contains('out')) return 'Gate Out';
    if (normalized.contains('in')) return 'Gate In';
    return trimmed;
  }

  Widget _statusChip(WarehouseReconciliationRecord item) {
    final key = item.normalizedStatus;
    if (item.isMatched) {
      return StatusChip(label: item.displayStatus, color: Colors.green);
    }
    if (key == 'quantity_mismatch') {
      return StatusChip(label: item.displayStatus, color: Colors.orange);
    }
    if (key == 'pending_grn' || key == 'grn_not_posted') {
      return StatusChip(label: item.displayStatus, color: Colors.red);
    }
    if (item.isException) {
      return StatusChip(label: item.displayStatus, color: Colors.red);
    }
    if (item.isApproved) {
      return StatusChip(label: item.displayStatus, color: Colors.blue);
    }
    if (item.isClosed) {
      return StatusChip(label: item.displayStatus, color: Colors.grey);
    }
    return StatusChip(label: item.displayStatus, color: Colors.orange);
  }

  /// Side-by-side comparison of the gate-entry values vs the matched SAP GRN's
  /// values. Which rows to render is driven by the reason code so the user
  /// immediately sees where the mismatch is — e.g. VENDOR_MISMATCH renders the
  /// vendor name + code rows; QUANTITY_MISMATCH renders the qty row.
  ///
  /// For exception statuses we don't recognise (or when the reason code is
  /// vague), we fall back to rendering every comparable field — better to
  /// over-show than to hide the actual culprit.
  ///
  /// Returns SizedBox.shrink() for statuses with nothing to compare
  /// (matched / pending_grn / pending_gate_entry / grn_not_posted).
  Widget _buildComparisonSection(
    BuildContext context,
    WarehouseGateEntryDetail entry,
  ) {
    // MULTIPLE_GRN_FOUND has a list of GRN numbers, not a side-by-side diff.
    if (record.reasonCode == ReasonCode.multipleGrnFound) {
      return Column(
        children: [
          _sectionCard(
            context,
            title: 'Duplicate GRNs Detected',
            child: _DuplicateGrnList(
              challanNo: entry.challanNo,
              duplicateGrnNumbers: record.duplicateGrnNumbers.isNotEmpty
                  ? record.duplicateGrnNumbers
                  : [
                      // Fall back to the single matchedGrnNumber if the array
                      // wasn't sent (e.g. older backend response).
                      if (record.matchedGrnNumber.isNotEmpty)
                        record.matchedGrnNumber,
                    ],
              displayReason: record.displayReason,
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    final rows = _comparisonRows(entry);
    if (rows.isEmpty) return const SizedBox.shrink();

    final reasonText = record.displayReason.isNotEmpty
        ? record.displayReason
        : 'See highlighted fields below.';

    return Column(
      children: [
        _sectionCard(
          context,
          title: 'Comparison: Gate Entry vs SAP GRN',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reasonText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              _ComparisonTable(rows: rows),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  List<_ComparisonRow> _comparisonRows(WarehouseGateEntryDetail entry) {
    // Gate-entry side: from the live entry payload (what gate security typed).
    // Items contribute materialCode + summed qty.
    final entryMaterials = entry.items
        .map((i) => i.materialCode)
        .where((c) => c.trim().isNotEmpty)
        .toSet()
        .join(', ');
    final entryQty = entry.items.fold<num>(
      0,
      (sum, item) => sum + item.challanQty,
    );

    // GRN side: from the reconciliation record (populated by backend on
    // exception rows). Fields may be empty if backend hasn't shipped yet;
    // the ComparisonTable renders a dim "—" placeholder when that happens.
    final grnVendorName = record.grnVendorName;
    final grnVendorCode = record.grnVendorCode;
    final grnPo = record.poNumber;
    final grnMaterial = record.materialCode;
    final grnQty = record.grnQty;

    // Helper: build a row, marking it as "different" when both sides have a
    // value and they don't match (trim + case-insensitive for strings).
    _ComparisonRow row({
      required String label,
      required String entryValue,
      required String grnValue,
    }) {
      final left = entryValue.trim();
      final right = grnValue.trim();
      final bothPresent = left.isNotEmpty && right.isNotEmpty;
      final differs = bothPresent && left.toLowerCase() != right.toLowerCase();
      return _ComparisonRow(
        label: label,
        entryValue: left,
        grnValue: right,
        differs: differs,
      );
    }

    // Exact-match against the stable reason-code vocabulary confirmed by
    // backend (lib/features/warehouse/domain/models/warehouse_reconciliation.dart
    // ReasonCode). Falls through to a permissive "show everything" view for
    // any future code we haven't seen yet, so the screen never goes blank.
    switch (record.reasonCode) {
      case ReasonCode.vendorMismatch:
      case ReasonCode.vendorMissing:
        return [
          row(
            label: 'Vendor Name',
            entryValue: entry.vendorName,
            grnValue: grnVendorName,
          ),
          row(
            label: 'Vendor Code',
            entryValue: entry.vendorCode,
            grnValue: grnVendorCode,
          ),
        ];

      case ReasonCode.poOrMaterialMismatch:
        // Diff could be on either side — render both so the user sees which
        // one is the culprit (the highlighted row).
        return [
          row(
            label: 'PO Number',
            entryValue: entry.poNumber,
            grnValue: grnPo,
          ),
          row(
            label: 'Material Code',
            entryValue: entryMaterials,
            grnValue: grnMaterial,
          ),
        ];

      case ReasonCode.qtyMismatch:
        return [
          row(
            label: 'Quantity',
            entryValue: entryQty == 0 ? '' : entryQty.toString(),
            grnValue: grnQty == 0 ? '' : grnQty.toString(),
          ),
          if (record.qtyVariance != 0)
            _ComparisonRow(
              label: 'Qty Variance',
              entryValue: '',
              grnValue: record.qtyVariance.toString(),
              differs: true,
            ),
        ];

      case ReasonCode.multipleGrnFound:
        // Rendered separately as a list of GRN numbers — return empty so the
        // section card switches to _buildDuplicateGrnSection instead.
        return const [];

      case ReasonCode.matched:
      case ReasonCode.awaitingGrn:
      case ReasonCode.grnMissing:
        // Nothing to compare for these.
        return const [];
    }

    // Unknown reason code on an exception row — show every comparable field,
    // diffs auto-highlight the culprit. Better to over-show than hide.
    if (record.isException) {
      return [
        row(
          label: 'Vendor Name',
          entryValue: entry.vendorName,
          grnValue: grnVendorName,
        ),
        row(
          label: 'Vendor Code',
          entryValue: entry.vendorCode,
          grnValue: grnVendorCode,
        ),
        row(
          label: 'PO Number',
          entryValue: entry.poNumber,
          grnValue: grnPo,
        ),
        row(
          label: 'Material Code',
          entryValue: entryMaterials,
          grnValue: grnMaterial,
        ),
        row(
          label: 'Quantity',
          entryValue: entryQty == 0 ? '' : entryQty.toString(),
          grnValue: grnQty == 0 ? '' : grnQty.toString(),
        ),
      ];
    }

    return const [];
  }
}

class _ComparisonRow {
  final String label;
  final String entryValue;
  final String grnValue;
  final bool differs;
  const _ComparisonRow({
    required this.label,
    required this.entryValue,
    required this.grnValue,
    required this.differs,
  });
}

class _ComparisonTable extends StatelessWidget {
  final List<_ComparisonRow> rows;
  const _ComparisonTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final headerStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        );

    Widget cell(String text, {bool differs = false, bool empty = false}) {
      final display = empty ? '—' : text;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Text(
          display,
          style: TextStyle(
            color: empty
                ? colorScheme.onSurfaceVariant
                : (differs ? Colors.red.shade700 : null),
            fontWeight: differs ? FontWeight.w700 : FontWeight.w500,
            fontStyle: empty ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12),
                  child: Text('Field', style: headerStyle),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12),
                  child: Text('Gate Entry', style: headerStyle),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10, horizontal: 12),
                  child: Text('SAP GRN', style: headerStyle),
                ),
              ],
            ),
            for (var i = 0; i < rows.length; i++)
              TableRow(
                decoration: BoxDecoration(
                  color: rows[i].differs
                      ? Colors.red.withValues(alpha: 0.06)
                      : (i.isOdd
                          ? colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.25)
                          : null),
                  border: i == rows.length - 1
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.4),
                          ),
                        ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 12),
                    child: Text(
                      rows[i].label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  cell(
                    rows[i].entryValue,
                    differs: rows[i].differs,
                    empty: rows[i].entryValue.isEmpty,
                  ),
                  cell(
                    rows[i].grnValue,
                    differs: rows[i].differs,
                    empty: rows[i].grnValue.isEmpty,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// MULTIPLE_GRN_FOUND view: shows every SAP GRN number that matched the
/// challan so the operator can pick which one is the real GRN and reject
/// the duplicate(s). No side-by-side diff is meaningful here.
class _DuplicateGrnList extends StatelessWidget {
  final String challanNo;
  final List<String> duplicateGrnNumbers;
  final String displayReason;
  const _DuplicateGrnList({
    required this.challanNo,
    required this.duplicateGrnNumbers,
    required this.displayReason,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayReason.isNotEmpty
              ? displayReason
              : 'More than one SAP GRN was found for this challan.',
          style: labelStyle,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('Challan: ', style: labelStyle),
              Text(
                challanNo.isEmpty ? '—' : challanNo,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (duplicateGrnNumbers.isEmpty)
          Text(
            'No duplicate GRN numbers were returned by the server.',
            style: labelStyle,
          )
        else ...[
          Text(
            '${duplicateGrnNumbers.length} GRN${duplicateGrnNumbers.length == 1 ? '' : 's'} matched this challan:',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: duplicateGrnNumbers
                .map(
                  (grn) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.deepOrange.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy_all,
                            size: 14, color: Colors.deepOrange),
                        const SizedBox(width: 6),
                        Text(
                          grn,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

/// Renders every challan item captured at gate-entry time. On wide screens
/// it's a 4-column table; on mobile each item collapses to a card so the
/// columns don't get crushed.
class _GateEntryItemsTable extends StatelessWidget {
  final List<WarehouseGateEntryItem> items;
  const _GateEntryItemsTable({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMob = isMobile(context);
    final headerStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        );

    if (isMob) {
      return Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Line ${i + 1}',
                    style: headerStyle,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    items[i].materialCode.isEmpty
                        ? '—'
                        : items[i].materialCode,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text('PO: ${items[i].poNumber.isEmpty ? '—' : items[i].poNumber}'),
                  Text(
                    'Qty: ${items[i].challanQty} '
                    '${items[i].uom.isEmpty ? '' : items[i].uom}',
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    Widget headerCell(String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Text(text, style: headerStyle),
        );
    Widget bodyCell(String text, {bool bold = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Text(
            text.isEmpty ? '—' : text,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(48),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1.2),
            4: FlexColumnWidth(0.8),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
              ),
              children: [
                headerCell('#'),
                headerCell('Material Code'),
                headerCell('PO Number'),
                headerCell('Qty'),
                headerCell('UOM'),
              ],
            ),
            for (var i = 0; i < items.length; i++)
              TableRow(
                decoration: BoxDecoration(
                  color: i.isOdd
                      ? colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.25)
                      : null,
                  border: i == items.length - 1
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.4),
                          ),
                        ),
                ),
                children: [
                  bodyCell('${i + 1}'),
                  bodyCell(items[i].materialCode, bold: true),
                  bodyCell(items[i].poNumber),
                  bodyCell(items[i].challanQty.toString(), bold: true),
                  bodyCell(items[i].uom),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
