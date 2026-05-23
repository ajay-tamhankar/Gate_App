import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../domain/models/gate_entry.dart';
import '../domain/services/gate_pass_pdf_service.dart';
import 'controllers/gate_entry_detail_controller.dart';
import 'controllers/gate_entry_controller.dart';
import 'gate_entry_form_page.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import '../../warehouse/data/warehouse_repository_impl.dart';
import '../../warehouse/domain/models/warehouse_gate_entry.dart';
import '../../warehouse/presentation/controllers/warehouse_providers.dart';
import '../../warehouse/presentation/warehouse_grn_create_page.dart';

class GateEntryDetailPage extends ConsumerWidget {
  final String entryId;
  const GateEntryDetailPage({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    
    // For exec, show the pending GRN view. Otherwise show the standard operations view.
    if (role == UserRole.warehouseExecutive) {
      return _WarehouseGateEntryDetailView(entryId: entryId);
    }
    return _GateEntryDetailSecurityView(entryId: entryId);
  }
}

class _GateEntryDetailSecurityView extends ConsumerStatefulWidget {
  const _GateEntryDetailSecurityView({required this.entryId});

  final String entryId;

  @override
  ConsumerState<_GateEntryDetailSecurityView> createState() => _GateEntryDetailSecurityViewState();
}

class _GateEntryDetailSecurityViewState extends ConsumerState<_GateEntryDetailSecurityView> {
  bool _canEdit(UserRole? role) {
    return role == UserRole.warehouseManager ||
        role == UserRole.whMgr ||
        role == UserRole.admin;
  }

  Future<void> _printGatePass(BuildContext context, GateEntry entry) async {
    try {
      await gatePassPdfService.printGatePass(entry);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open gate pass print: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  Future<void> _shareGatePass(BuildContext context, GateEntry entry) async {
    try {
      await gatePassPdfService.shareGatePass(entry);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not share gate pass: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  Future<void> _openEditPage(BuildContext context, GateEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GateEntryFormPage(initialEntry: entry),
      ),
    );
    if (!mounted) return;
    await ref
        .read(gateEntryDetailControllerProvider(widget.entryId).notifier)
        .fetch();
    await ref.read(gateEntryControllerProvider.notifier).fetchEntries();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return DateFormat('dd MMM yyyy  •  hh:mm a').format(dt.toLocal());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'inward_created':
        return Colors.orange;
      case 'verification_pending':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.teal;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'inward_created':
        return 'Pending';
      case 'verification_pending':
        return 'In Review';
      case 'approved':
        return 'Approved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state =
        ref.watch(gateEntryDetailControllerProvider(widget.entryId));
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Entry Details'),
        actions: [
          if (state.entry != null)
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Print Gate Pass',
              onPressed: () => _printGatePass(context, state.entry!),
            ),
          if (state.entry != null)
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share Gate Pass',
              onPressed: () => _shareGatePass(context, state.entry!),
            ),
          if (state.entry != null && _canEdit(role))
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Gate Entry',
              onPressed: () => _openEditPage(context, state.entry!),
            ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? _buildDetailSkeleton()
          : state.error != null
              ? Center(child: Text('Error: ${state.error}'))
              : state.entry == null
                  ? const Center(child: Text('Entry not found'))
                  : _buildDetailView(context, state.entry!, role),
    );
  }

  Widget _buildDetailSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLoader(width: double.infinity, height: 96),
            SizedBox(height: 16),
            SkeletonLoader(width: double.infinity, height: 64),
            SizedBox(height: 16),
            SkeletonLoader(width: double.infinity, height: 180),
            SizedBox(height: 16),
            SkeletonLoader(width: double.infinity, height: 220),
            SizedBox(height: 16),
            SkeletonLoader(width: double.infinity, height: 140),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView(
      BuildContext context, GateEntry entry, UserRole? role) {
    final isGateIn = entry.gateMovement == GateMovement.inMovement;
    final directionColor = isGateIn ? Colors.indigo : Colors.deepOrange;
    final sc = _statusColor(entry.status);
    final qty = entry.items.isNotEmpty
        ? entry.items.fold(0, (sum, i) => sum + i.challanQty)
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade900, Colors.indigo.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isGateIn ? Icons.login : Icons.logout,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.challanNo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isGateIn ? 'Gate In Entry' : 'Gate Out Entry',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sc.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sc.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      _statusLabel(entry.status),
                      style: TextStyle(
                        color: sc,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Quick-stats row ───────────────────────────────────
            Row(
              children: [
                _statChip(
                  context,
                  icon: Icons.access_time,
                  label: _formatDate(entry.gateTimestamp),
                  color: directionColor,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Vendor & Transporter ─────────────────────────────
            _sectionCard(
              context,
              title: 'Party Information',
              icon: Icons.business_outlined,
              children: [
                _detailRow(context, 'Vendor Name', entry.vendorName),
                if (entry.vendorCode.isNotEmpty)
                  _detailRow(context, 'Vendor Code', entry.vendorCode),
                _detailRow(
                    context, 'Transporter', entry.transporterName),
              ],
            ),
            const SizedBox(height: 10),

            // ── Vehicle & Driver ─────────────────────────────────
            _sectionCard(
              context,
              title: 'Vehicle & Driver',
              icon: Icons.local_shipping_outlined,
              children: [
                _detailRow(
                  context,
                  'Vehicle No',
                  entry.vehicleNo.isEmpty ? 'N/A' : entry.vehicleNo,
                ),
                _detailRow(
                  context,
                  'LR Number',
                  entry.lrNumber.isEmpty ? 'N/A' : entry.lrNumber,
                ),
                if (entry.driverContactNo.isNotEmpty)
                  _detailRow(
                      context, 'Driver Contact', entry.driverContactNo),
              ],
            ),
            const SizedBox(height: 10),

            // ── Items ─────────────────────────────────────────────
            if (entry.items.isNotEmpty) ...[
              _sectionCard(
                context,
                title: 'Items  ($qty total qty)',
                icon: Icons.inventory_2_outlined,
                children: [
                  ...entry.items.map(
                    (item) => _itemRow(context, item),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            // ── Meta ─────────────────────────────────────────────
            _sectionCard(
              context,
              title: 'Entry Information',
              icon: Icons.info_outline,
              children: [
                if (entry.gateEntryNo != null)
                  _detailRow(
                      context, 'Gate Entry No', entry.gateEntryNo!),
                _detailRow(
                    context, 'Direction', isGateIn ? 'Gate In' : 'Gate Out'),
                _detailRow(
                    context, 'Status', _statusLabel(entry.status)),
                _detailRow(
                    context, 'Entry Time', _formatDate(entry.gateTimestamp)),
                if (entry.noOfLineItems != null)
                  _detailRow(context, 'No. of Line Items',
                      entry.noOfLineItems.toString()),
                if (entry.remark != null && entry.remark!.isNotEmpty)
                  _detailRow(context, 'Remark', entry.remark!),
                if (entry.createdBy != null)
                  _detailRow(context, 'Created By', entry.createdBy!),
                if (entry.gateOutTimestamp != null)
                  _detailRow(context, 'Gate Out Time', _formatDate(entry.gateOutTimestamp)),
                if (entry.gateOutBy != null)
                  _detailRow(context, 'Gate Out By', entry.gateOutBy!),
              ],
            ),

            // ── Action buttons ────────────────────────────────────
            _buildActionSection(context, entry, role),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
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
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Icon(icon,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(BuildContext context, dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.category_outlined,
              size: 14,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.materialCode ?? 'N/A',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  'PO: ${item.poNumber}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Qty: ${item.challanQty} ${item.uom}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildActionSection(
      BuildContext context, GateEntry entry, UserRole? role) {
    final status = entry.status;
    final canEdit = _canEdit(role);
    final canVerify =
        role == UserRole.warehouseExecutive || role.isAdminOrWarehouseManager;
    final canApprove = role == UserRole.warehouseManager ||
        role == UserRole.admin ||
        role == UserRole.whMgr;
    final canClose = canApprove;

    final showVerify = status == 'inward_created' && canVerify;
    final showApprove = status == 'verification_pending' && canApprove;
    final showClose = status == 'approved' && canClose;
    final showEdit = canEdit;
    final showGateOut = entry.gateOutTimestamp == null &&
        entry.gateMovement == GateMovement.inMovement &&
        status != 'closed' &&
        (role == UserRole.gateSecurity ||
            role == UserRole.warehouseExecutive ||
            role.isAdminOrWarehouseManager);

    if (!showVerify && !showApprove && !showClose && !showEdit && !showGateOut) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          if (showEdit)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openEditPage(context, entry),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Entry'),
              ),
            ),
          if (showEdit && (showVerify || showApprove || showClose))
            const SizedBox(height: 10),
          Row(
            children: [
              if (showVerify)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmAndAct(
                      context,
                      entry: entry,
                      title: 'Verify Entry',
                      message: 'Verify this gate entry?',
                      action: () => ref
                          .read(gateEntryControllerProvider.notifier)
                          .verifyEntry(entry.id),
                    ),
                    icon: const Icon(Icons.verified_outlined, size: 18),
                    label: const Text('Verify'),
                  ),
                ),
              if (showApprove) ...[
                if (showVerify) const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmAndAct(
                      context,
                      entry: entry,
                      title: 'Approve Entry',
                      message: 'Approve this gate entry?',
                      action: () => ref
                          .read(gateEntryControllerProvider.notifier)
                          .approveEntry(entry.id),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Approve'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
              if (showClose) ...[
                if (showVerify || showApprove) const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmAndAct(
                      context,
                      entry: entry,
                      title: 'Close Entry',
                      message: 'Close this gate entry?',
                      action: () => ref
                          .read(gateEntryControllerProvider.notifier)
                          .closeEntry(entry.id),
                    ),
                    icon: const Icon(Icons.lock_outline, size: 18),
                    label: const Text('Close'),
                  ),
                ),
              ],
            ],
          ),
          if (showGateOut) ...[
            if (showEdit || showVerify || showApprove || showClose)
              const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _gateOutWithRemarks(context, entry),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Gate Out'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _gateOutWithRemarks(BuildContext context, GateEntry entry) async {
    final remarksController = TextEditingController();
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Record Gate Out'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to record the vehicle exit?'),
            const SizedBox(height: 16),
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks (Optional)',
                hintText: 'e.g. Vehicle exited after unloading',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    final success = await ref
        .read(gateEntryControllerProvider.notifier)
        .gateOutEntry(entry.id, remarks: remarksController.text.trim());

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Gate out recorded' : 'Gate out failed'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
    if (success) Navigator.of(context).pop();
  }

  Future<void> _confirmAndAct(
    BuildContext context, {
    required GateEntry entry,
    required String title,
    required String message,
    required Future<bool> Function() action,
  }) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (proceed != true) return;
    final success = await action();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Action completed' : 'Action failed'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: success ? Colors.green : Colors.redAccent,
      ),
    );
    if (success) Navigator.of(context).pop();
  }
}



// ---------------------------------------------------------------------------
// WAREHOUSE ENTRY VIEW (merged from warehouse_gate_entry_detail_page.dart)
// ---------------------------------------------------------------------------

class _WarehouseGateEntryDetailView extends ConsumerStatefulWidget {
  final String entryId;

  const _WarehouseGateEntryDetailView({required this.entryId});

  @override
  ConsumerState<_WarehouseGateEntryDetailView> createState() =>
      _WarehouseGateEntryDetailViewState();
}

class _WarehouseGateEntryDetailViewState
    extends ConsumerState<_WarehouseGateEntryDetailView> {
  final _vendorController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _poController = TextEditingController();
  final _remarksController = TextEditingController();

  bool isEditing = false;
  bool _verifiedLocally = false;
  String? _lastSyncedEntryId;

  @override
  void dispose() {
    _vendorController.dispose();
    _vehicleController.dispose();
    _poController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  ({
    bool isInward,
    String gatePassNo,
    DateTime? entryDate,
    List<GatePassItemInfo> items,
  }) _warehouseGatePassData(WarehouseGateEntryDetail entry) {
    final movement = entry.gateMovement.trim().toLowerCase();
    final isInward = movement.isEmpty || movement.contains('in');
    final gatePassNo = entry.gateEntryNo.trim().isNotEmpty
        ? entry.gateEntryNo.trim()
        : entry.id;
    return (
      isInward: isInward,
      gatePassNo: gatePassNo,
      entryDate: isInward ? entry.entryTime : entry.gateOutTimestamp,
      items: entry.items
          .map((item) => GatePassItemInfo(
                materialCode: item.materialCode,
                poNumber: item.poNumber,
                challanQty: item.challanQty,
                uom: item.uom,
              ))
          .toList(),
    );
  }

  Future<void> _printWarehouseGatePass(
      BuildContext context, WarehouseGateEntryDetail entry) async {
    try {
      final data = _warehouseGatePassData(entry);
      await gatePassPdfService.printGatePassFromFields(
        gatePassNo: data.gatePassNo,
        isInward: data.isInward,
        entryDate: data.entryDate,
        vendorName: entry.vendorName,
        challanNo: entry.challanNo,
        vehicleNo: entry.vehicleNo,
        lrNumber: entry.lrNumber,
        items: data.items,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open gate pass print: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  Future<void> _shareWarehouseGatePass(
      BuildContext context, WarehouseGateEntryDetail entry) async {
    try {
      final data = _warehouseGatePassData(entry);
      await gatePassPdfService.shareGatePassFromFields(
        gatePassNo: data.gatePassNo,
        isInward: data.isInward,
        entryDate: data.entryDate,
        vendorName: entry.vendorName,
        challanNo: entry.challanNo,
        vehicleNo: entry.vehicleNo,
        lrNumber: entry.lrNumber,
        items: data.items,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not share gate pass: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  Future<void> _openAttachment(String attachmentId) async {
    final repo = ref.read(warehouseRepositoryProvider);
    try {
      final url = await repo.getAttachmentUrl(widget.entryId, attachmentId);
      if (url == null || url.isEmpty) {
        throw Exception('Attachment URL not found');
      }
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          content: Text('Vendor Name, Vehicle Number, and PO Number are required.'),
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

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(warehouseGateEntryDetailProvider(widget.entryId));
    final isMob = isMobile(context);
    final verificationState =
        ref.watch(warehouseGateEntryVerificationControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final isManager = role == UserRole.warehouseManager || role == UserRole.whMgr;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Entry Details'),
        actions: [
          detail.maybeWhen(
            data: (entry) => IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Print Gate Pass',
              onPressed: () => _printWarehouseGatePass(context, entry),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          detail.maybeWhen(
            data: (entry) => IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: 'Share Gate Pass',
              onPressed: () => _shareWarehouseGatePass(context, entry),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
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
          final canVerify = !isManager && entry.canEdit && !isVerified;
          final canCreateGrn =
              !isManager && entry.grnStatus.toLowerCase() != 'completed' && isVerified;
          final displayStatus = entry.isClosed
              ? 'Closed'
              : entry.isApproved
                  ? 'Approved'
                  : isVerified
                      ? 'Verified'
                      : entry.statusLabel;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              SectionHeader(
                title: entry.gateEntryNo,
                subtitle: 'Challan: ${entry.challanNo} | ${_formatDate(entry.entryTime)}',
                trailing: _buildStatusChip(context, displayStatus),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                      _buildReadOnlyTile(
                        context,
                        label: 'Vendor Code',
                        value: entry.vendorCode,
                        isMobile: isMob,
                      ),
                      _buildReadOnlyTile(
                        context,
                        label: 'LR Number',
                        value: entry.lrNumber,
                        isMobile: isMob,
                      ),
                      _buildReadOnlyTile(
                        context,
                        label: 'Driver Contact',
                        value: entry.driverContactNo,
                        isMobile: isMob,
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
              if (!isManager)
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                  if (success == true && context.mounted) {
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
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ).copyWith(labelText: label),
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
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(value.isEmpty ? 'Not available' : value),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachments(BuildContext context, WarehouseGateEntryDetail entry) {
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
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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



