import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import '../data/warehouse_repository_impl.dart';
import '../domain/models/warehouse_gate_entry.dart';
import 'controllers/warehouse_providers.dart';
import 'warehouse_grn_create_page.dart';

class WarehouseGateEntryDetailPage extends ConsumerStatefulWidget {
  final String entryId;

  const WarehouseGateEntryDetailPage({super.key, required this.entryId});

  @override
  ConsumerState<WarehouseGateEntryDetailPage> createState() =>
      _WarehouseGateEntryDetailPageState();
}

class _WarehouseGateEntryDetailPageState
    extends ConsumerState<WarehouseGateEntryDetailPage> {
  final _vendorController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _poController = TextEditingController();
  final _remarksController = TextEditingController();

  bool isEditing = false;
  bool _verifiedLocally = false;
  bool _approvedLocally = false;
  bool _closedLocally = false;
  String? _lastSyncedEntryId;

  @override
  void dispose() {
    _vendorController.dispose();
    _vehicleController.dispose();
    _poController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  Future<void> _openAttachment(String attachmentId) async {
    final repo = ref.read(warehouseRepositoryProvider);
    try {
      final url = await repo.getAttachmentUrl(widget.entryId, attachmentId);
      if (url == null || url.isEmpty) {
        throw Exception('Attachment URL not found');
      }
      final uri = Uri.parse(url);
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open attachment')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open attachment: $e')),
      );
    }
  }

  void _syncControllers(WarehouseGateEntryDetail entry) {
    if (isEditing && _lastSyncedEntryId == entry.id) return;
    _vendorController.text = entry.vendorName;
    _vehicleController.text = entry.vehicleNo;
    _poController.text = entry.poNumber;
    _remarksController.text = entry.remarks;
    if (entry.isVerified) {
      _verifiedLocally = false;
    }
    _lastSyncedEntryId = entry.id;
  }

  void _enterEditMode(WarehouseGateEntryDetail entry) {
    _syncControllers(entry);
    setState(() => isEditing = true);
  }

  void _cancelEditing(WarehouseGateEntryDetail entry) {
    _vendorController.text = entry.vendorName;
    _vehicleController.text = entry.vehicleNo;
    _poController.text = entry.poNumber;
    _remarksController.text = entry.remarks;
    setState(() => isEditing = false);
  }

  Future<void> _saveVerification(WarehouseGateEntryDetail entry) async {
    final vendorName = _vendorController.text.trim();
    final vehicleNo = _vehicleController.text.trim();
    final poNumber = _poController.text.trim();
    final remarks = _remarksController.text.trim();

    if (vendorName.isEmpty || vehicleNo.isEmpty || poNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vendor Name, Vehicle Number, and PO Number are required.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = await ref
        .read(warehouseGateEntryVerificationControllerProvider.notifier)
        .verifyEntry(
          entry.id,
          WarehouseGateEntryVerificationRequest(
            vendorName: vendorName,
            vehicleNo: vehicleNo,
            poNumber: poNumber,
            remarks: remarks,
            isVerified: true,
          ),
        );

    if (!mounted) return;

    if (success) {
      _verifiedLocally = true;
      ref.invalidate(warehouseGateEntryDetailProvider(widget.entryId));
      ref.invalidate(warehouseGateEntriesProvider);
      ref.invalidate(warehouseDashboardProvider);
      ref.invalidate(warehouseReconciliationSummaryProvider);
      setState(() => isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification saved successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final state = ref.read(warehouseGateEntryVerificationControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save verification: ${state.error}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _approveGateEntry(WarehouseGateEntryDetail entry) async {
    final success = await ref
        .read(warehouseGateEntryManagerActionControllerProvider.notifier)
        .approve(entry.id);

    if (!mounted) return;

    if (success) {
      setState(() {
        _approvedLocally = true;
        _closedLocally = false;
      });
      ref.invalidate(warehouseGateEntryDetailProvider(widget.entryId));
      ref.invalidate(warehouseGateEntriesProvider);
      ref.invalidate(warehouseDashboardProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gate entry approved successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final state = ref.read(warehouseGateEntryManagerActionControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve gate entry: ${state.error}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _closeGateEntry(WarehouseGateEntryDetail entry) async {
    final success = await ref
        .read(warehouseGateEntryManagerActionControllerProvider.notifier)
        .close(entry.id);

    if (!mounted) return;

    if (success) {
      setState(() {
        _closedLocally = true;
        _approvedLocally = true;
      });
      ref.invalidate(warehouseGateEntryDetailProvider(widget.entryId));
      ref.invalidate(warehouseGateEntriesProvider);
      ref.invalidate(warehouseDashboardProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gate entry closed successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final state = ref.read(warehouseGateEntryManagerActionControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to close gate entry: ${state.error}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(warehouseGateEntryDetailProvider(widget.entryId));
    final isMob = isMobile(context);
    final verificationState =
        ref.watch(warehouseGateEntryVerificationControllerProvider);
    final managerActionState =
        ref.watch(warehouseGateEntryManagerActionControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final isManager =
        role == UserRole.warehouseManager || role == UserRole.whMgr;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Entry Details'),
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
          _syncControllers(entry);
          final isVerified = entry.isVerified || _verifiedLocally;
          final isApproved = entry.isApproved || _approvedLocally;
          final isClosed = entry.isClosed || _closedLocally;
          final canVerify = !isManager && entry.canEdit && !isVerified;
          final canCreateGrn =
              !isManager && entry.grnStatus.toLowerCase() != 'completed' && isVerified;
          final displayStatus = isClosed
              ? 'Closed'
              : isApproved
                  ? 'Approved'
                  : isVerified
                      ? 'Verified'
                      : entry.statusLabel;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SectionHeader(
                title: entry.gateEntryNo,
                subtitle:
                    'Challan: ${entry.challanNo} | ${_formatDate(entry.entryTime)}',
                trailing: _buildStatusChip(context, displayStatus),
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
                  child: Wrap(
                    runSpacing: 16,
                    spacing: 16,
                    children: [
                      _buildEditableField(
                        context,
                        label: 'Vendor Name',
                        controller: _vendorController,
                        value: entry.vendorName,
                        isMobile: isMob,
                        enabled: !isManager && isEditing,
                        highlight: !isManager && isEditing,
                      ),
                      _buildEditableField(
                        context,
                        label: 'Vehicle Number',
                        controller: _vehicleController,
                        value: entry.vehicleNo,
                        isMobile: isMob,
                        enabled: !isManager && isEditing,
                        highlight: !isManager && isEditing,
                      ),
                      _buildEditableField(
                        context,
                        label: 'PO Number',
                        controller: _poController,
                        value: entry.poNumber,
                        isMobile: isMob,
                        enabled: !isManager && isEditing,
                        highlight: !isManager && isEditing,
                      ),
                      _buildEditableField(
                        context,
                        label: 'Remarks',
                        controller: _remarksController,
                        value: entry.remarks,
                        isMobile: isMob,
                        enabled: !isManager && isEditing,
                        maxLines: 3,
                        highlight: !isManager && isEditing,
                      ),
                      _buildReadOnlyTile(
                        context,
                        label: 'Transporter',
                        value: entry.transporterName,
                        isMobile: isMob,
                      ),
                      _buildReadOnlyTile(
                        context,
                        label: 'Gate Movement',
                        value: entry.gateMovement,
                        isMobile: isMob,
                      ),
                      _buildReadOnlyTile(
                        context,
                        label: 'Status',
                        value: displayStatus,
                        isMobile: isMob,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (isManager)
                _buildManagerActions(
                  context,
                  entry,
                  isApproved: isApproved,
                  isClosed: isClosed,
                  isLoading: managerActionState.isLoading,
                )
              else
                _buildVerificationActions(
                  context,
                  entry,
                  isVerified: isVerified,
                  canVerify: canVerify,
                  isSaving: verificationState.isLoading,
                ),
              const SizedBox(height: 24),
              Text(
                'Material Details',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              isMob ? _buildItemList(entry) : _buildItemTable(context, entry),
              if (!isManager) ...[
                const SizedBox(height: 24),
                _buildCreateGrnSection(context, entry, canCreateGrn),
              ],
              const SizedBox(height: 24),
              Text(
                'View Attachments',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildAttachments(context, entry),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final normalized = status.toLowerCase();
    final color = normalized.contains('closed')
        ? Colors.grey
        : normalized.contains('approved')
            ? Colors.green
            : normalized.contains('verified')
                ? Colors.blue
                : Colors.orange;

    return Chip(
      label: Text(status),
      backgroundColor: color.withValues(alpha: 0.12),
      side: BorderSide(color: color.withValues(alpha: 0.35)),
      labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildVerificationActions(
    BuildContext context,
    WarehouseGateEntryDetail entry, {
    required bool isVerified,
    required bool canVerify,
    required bool isSaving,
  }) {
    if (!entry.canEdit) {
      return Text(
        'Verification is locked because GRN is already created.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (!isEditing && !isVerified)
          FilledButton.icon(
            onPressed: canVerify ? () => _enterEditMode(entry) : null,
            icon: const Icon(Icons.verified_user),
            label: const Text('Verify'),
          ),
        if (!isEditing && isVerified)
          Text(
            'This entry is already verified.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        if (isEditing)
          FilledButton.icon(
            onPressed: isSaving ? null : () => _saveVerification(entry),
            icon: isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(isSaving ? 'Saving...' : 'Save Verification'),
          ),
        if (isEditing)
          OutlinedButton(
            onPressed: isSaving ? null : () => _cancelEditing(entry),
            child: const Text('Cancel'),
          ),
      ],
    );
  }

  Widget _buildManagerActions(
    BuildContext context,
    WarehouseGateEntryDetail entry, {
    required bool isApproved,
    required bool isClosed,
    required bool isLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manager Actions',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (!isApproved)
              FilledButton.icon(
                onPressed: isLoading ? null : () => _approveGateEntry(entry),
                icon: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.task_alt),
                label: const Text('Approve'),
              ),
            if (isApproved)
              OutlinedButton.icon(
                onPressed: isLoading || isClosed
                    ? null
                    : () => _closeGateEntry(entry),
                icon: isLoading && !isClosed
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_outline),
                label: Text(isClosed ? 'Closed' : 'Close'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isClosed
              ? 'This gate entry is already closed.'
              : isApproved
                  ? 'Gate entry approved. You can close it now.'
                  : 'Approve the gate entry before closing it.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildCreateGrnSection(
    BuildContext context,
    WarehouseGateEntryDetail entry,
    bool canCreateGrn,
  ) {
    if (entry.grnStatus.toLowerCase() == 'completed') {
      return Text(
        'GRN already created for this entry.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilledButton.icon(
          onPressed: canCreateGrn
              ? () async {
                  final success = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => WarehouseGrnCreatePage(entry: entry),
                    ),
                  );
                  if (success == true && mounted) {
                    ref.invalidate(warehouseGateEntriesProvider);
                    ref.invalidate(warehouseDashboardProvider);
                    ref.invalidate(warehouseReconciliationSummaryProvider);
                    Navigator.of(context).pop();
                  }
                }
              : null,
          icon: const Icon(Icons.note_add),
          label: const Text('Create GRN'),
        ),
        if (!canCreateGrn) ...[
          const SizedBox(height: 8),
          Text(
            'Please verify before creating GRN',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildEditableField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String value,
    required bool isMobile,
    required bool enabled,
    bool highlight = false,
    int maxLines = 1,
  }) {
    final width = isMobile ? double.infinity : 260.0;
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = highlight
        ? colorScheme.primary.withValues(alpha: 0.35)
        : colorScheme.outlineVariant.withValues(alpha: 0.5);

    return SizedBox(
      width: width,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled
              ? colorScheme.primary.withValues(alpha: 0.04)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: enabled
            ? TextField(
                controller: controller,
                maxLines: maxLines,
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                  isDense: true,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(value.isEmpty ? 'Not available' : value),
                ],
              ),
      ),
    );
  }

  Widget _buildReadOnlyTile(
    BuildContext context, {
    required String label,
    required String value,
    required bool isMobile,
  }) {
    return SizedBox(
      width: isMobile ? double.infinity : 260.0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(value.isEmpty ? 'Not available' : value),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments(
    BuildContext context,
    WarehouseGateEntryDetail entry,
  ) {
    if (entry.attachments.isEmpty) {
      return Text(
        'No attachments uploaded yet.',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }

    return Column(
      children: entry.attachments
          .map(
            (a) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.5),
                ),
              ),
              child: ListTile(
                title: Text(a.fileName),
                trailing: TextButton(
                  onPressed: () => _openAttachment(a.id),
                  child: const Text('View'),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildItemList(WarehouseGateEntryDetail entry) {
    return Column(
      children: entry.items.map((item) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
          child: ListTile(
            title: Text(item.materialCode),
            subtitle: Text('PO: ${item.poNumber} | UOM: ${item.uom}'),
            trailing: Text('Qty ${item.challanQty}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildItemTable(BuildContext context, WarehouseGateEntryDetail entry) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Material')),
          DataColumn(label: Text('PO Number')),
          DataColumn(label: Text('Qty')),
          DataColumn(label: Text('UOM')),
        ],
        rows: entry.items
            .map(
              (item) => DataRow(cells: [
                DataCell(Text(item.materialCode)),
                DataCell(Text(item.poNumber)),
                DataCell(Text(item.challanQty.toString())),
                DataCell(Text(item.uom)),
              ]),
            )
            .toList(),
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return DateFormat('MMM dd, yyyy | HH:mm').format(dt);
  }
}


