import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import '../../../core/ui/widgets/status_chip.dart';
import '../domain/models/warehouse_reconciliation.dart';
import 'controllers/warehouse_providers.dart';

class WarehouseReconciliationDetailPage extends ConsumerWidget {
  final WarehouseReconciliationRecord record;

  const WarehouseReconciliationDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final isManager =
        role == UserRole.warehouseManager || role == UserRole.whMgr;
    final managerId = session is Authenticated ? session.userId : '';
    final detail = ref.watch(warehouseGateEntryDetailProvider(record.gateEntryId));
    final actionState = ref.watch(warehouseReconciliationActionControllerProvider);
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
                    'Status: ${record.status} | ${record.date != null ? DateFormat('MMM dd, yyyy').format(record.date!) : 'No date'}',
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
                title: 'GRN Info',
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _infoBlock(context, 'Received Qty', '${record.receivedQty}', isMob),
                    _infoBlock(context, 'Accepted Qty', '${record.acceptedQty}', isMob),
                    _infoBlock(context, 'Rejected Qty', '${record.rejectedQty}', isMob),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                context,
                title: 'SAP Comparison',
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _infoBlock(context, 'Expected Qty', '${record.expectedQty}', isMob),
                    _infoBlock(context, 'Received Qty', '${record.receivedQty}', isMob),
                    _highlightBlock(
                      context,
                      'Difference',
                      '${record.differenceQty}',
                      isMob,
                      record.isException,
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
                    if (record.remarks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Remarks: ${record.remarks}'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (isManager)
                _buildActionArea(
                  context,
                  ref,
                  actionState.isLoading,
                  managerId,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionArea(
    BuildContext context,
    WidgetRef ref,
    bool isLoading,
    String managerId,
  ) {
    if (record.isPending) {
      return Text(
        'Waiting for reconciliation',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }

    final approveLabel = record.isException ? 'Approve with Remark' : 'Approve';
    final closeLabel = record.isException ? 'Close After Review' : 'Close';
    final showApprove = record.isMatched || record.isException;
    final showClose = record.isMatched || record.isException || record.isApproved;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (showApprove)
          FilledButton.icon(
            onPressed: isLoading
                ? null
                : () => _confirmAction(
                      context,
                      ref,
                      managerId: managerId,
                      isApprove: true,
                      requireRemarks: record.isException,
                    ),
            icon: const Icon(Icons.check_circle),
            label: Text(approveLabel),
          ),
        if (showClose)
          OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () => _confirmAction(
                      context,
                      ref,
                      managerId: managerId,
                      isApprove: false,
                      requireRemarks: record.isException,
                    ),
            icon: const Icon(Icons.lock),
            label: Text(closeLabel),
          ),
      ],
    );
  }

  Future<void> _confirmAction(
    BuildContext context,
    WidgetRef ref, {
    required String managerId,
    required bool isApprove,
    required bool requireRemarks,
  }) async {
    final remarksController = TextEditingController(
      text: isApprove ? 'Approved after verification' : 'Process completed',
    );

    final remarks = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Approve Entry' : 'Close Entry'),
        content: TextField(
          controller: remarksController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: requireRemarks ? 'Remarks (required)' : 'Remarks',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = remarksController.text.trim();
              if (requireRemarks && value.isEmpty) {
                return;
              }
              Navigator.of(context).pop(value);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (remarks == null) return;

    final controller =
        ref.read(warehouseReconciliationActionControllerProvider.notifier);
    final request = WarehouseReconciliationActionRequest(
      actorKey: isApprove ? 'approvedBy' : 'closedBy',
      actorId: managerId,
      remarks: remarks,
    );

    final success = isApprove
        ? await controller.approve(record.id, request)
        : await controller.close(record.id, request);

    if (!context.mounted) return;

    if (success) {
      ref.invalidate(warehouseManagerReconciliationsProvider);
      ref.invalidate(warehouseManagerDashboardSummaryProvider);
      ref.invalidate(warehouseReconciliationSummaryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isApprove ? 'Reconciliation approved' : 'Reconciliation closed'),
          backgroundColor: Colors.green,
        ),
      );
      if (!isApprove) {
        Navigator.of(context).pop();
      }
    } else {
      final state = ref.read(warehouseReconciliationActionControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Action failed: ${state.error}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
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
    if (item.isMatched) {
      return const StatusChip(label: 'Matched', color: Colors.green);
    }
    if (item.isException) {
      return const StatusChip(label: 'Exception', color: Colors.red);
    }
    if (item.isApproved) {
      return const StatusChip(label: 'Approved', color: Colors.blue);
    }
    if (item.isClosed) {
      return const StatusChip(label: 'Closed', color: Colors.grey);
    }
    return const StatusChip(label: 'Pending', color: Colors.orange);
  }
}