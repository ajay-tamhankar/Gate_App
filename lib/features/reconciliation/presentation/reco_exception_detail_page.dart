import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exception Details'),
        actions: const [
          LogoutAction(),
          SizedBox(width: 8),
        ],
      ),
      body: detailAsync.when(
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
    final detail = ref.watch(warehouseGateEntryDetailProvider(record.gateEntryId));
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
                title: record.gateEntryNo.isEmpty ? entry.gateEntryNo : record.gateEntryNo,
                subtitle:
                    'Status: ${record.displayStatus} | ${record.date != null ? DateFormat('MMM dd, yyyy - hh:mm a').format(record.date!) : 'No date'}',
                trailing: _statusChip(record),
              ),
              _sectionCard(
                context,
                title: 'Gate Entry Info',
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _infoBlock(context, 'Vendor', entry.vendorName, isMob),
                    _infoBlock(context, 'Vehicle', entry.vehicleNo, isMob),
                    _infoBlock(context, 'PO Number', entry.poNumber, isMob),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
}
