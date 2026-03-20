import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/widgets/logout_action.dart';
import 'controllers/gate_entry_detail_controller.dart';
import 'controllers/gate_entry_controller.dart';
import '../domain/models/gate_entry.dart';

class GateEntryDetailPage extends ConsumerStatefulWidget {
  final String entryId;

  const GateEntryDetailPage({super.key, required this.entryId});

  @override
  ConsumerState<GateEntryDetailPage> createState() =>
      _GateEntryDetailPageState();
}

class _GateEntryDetailPageState extends ConsumerState<GateEntryDetailPage> {



  Future<void> _openAttachment(String attachmentId) async {
    final controller =
        ref.read(gateEntryDetailControllerProvider(widget.entryId).notifier);
    final url = await controller.fetchAttachmentUrl(attachmentId);
    if (!mounted || url == null) return;

    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid attachment URL')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Attachment URL'),
          content: SelectableText(url),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gateEntryDetailControllerProvider(widget.entryId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Entry Details'),
        actions: const [
          LogoutAction(),
          SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                SkeletonLoader(width: 220, height: 32),
                SizedBox(height: 16),
                SkeletonLoader(width: double.infinity, height: 160),
                SizedBox(height: 24),
                SkeletonLoader(width: double.infinity, height: 260),
              ],
            )
          : state.entry == null
              ? Center(child: Text(state.error ?? 'Entry not found'))
              : _buildContent(context, state.entry!, state),
    );
  }

  Widget _buildContent(
      BuildContext context, GateEntry entry, GateEntryDetailState state) {
    final isMob = isMobile(context);
    final isGateIn = entry.gateMovement == GateMovement.inMovement;
    final timestamp = entry.gateTimestamp != null
        ? DateFormat('MMM dd, yyyy • HH:mm').format(entry.gateTimestamp!)
        : 'N/A';
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        SectionHeader(
          title: entry.gateEntryNo ?? 'Unknown',
          subtitle: 'Challan: ${entry.challanNo} • $timestamp',
        ),
        Card(
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
            padding: const EdgeInsets.all(24.0),
            child: Wrap(
              runSpacing: 16,
              spacing: 24,
              children: [
                _infoChip(
                  context,
                  'Direction',
                  isGateIn ? 'Gate In' : 'Gate Out',
                ),
                _infoChip(context, 'Vendor', entry.vendorName),
                _infoChip(context, 'Vehicle', entry.vehicleNo),
                _infoChip(context, 'Transporter', entry.transporterName),
                _infoChip(context, 'Status', entry.status),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Items',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        isMob ? _buildItemList(entry) : _buildItemTable(context, entry),
        const SizedBox(height: 24),
        _buildActionBar(context, entry, role),
        const SizedBox(height: 24),
        Text(
          'View Attachments',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (state.attachments.isEmpty)
          Text(
            'No attachments uploaded yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        const SizedBox(height: 12),
        if (state.uploadError != null)
          Text(
            state.uploadError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        const SizedBox(height: 8),
        ...state.attachments.map((a) => Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.5)),
              ),
              child: ListTile(
                title: Text(a.fileName),
                subtitle: Text('Attachment ID: ${a.id}'),
                trailing: TextButton(
                  onPressed: () => _openAttachment(a.id),
                  child: const Text('View'),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildActionBar(
      BuildContext context, GateEntry entry, UserRole? role) {
    final status = entry.status;
    final canVerify =
        role == UserRole.warehouseExecutive || role == UserRole.admin;
    final canApprove = role == UserRole.warehouseManager ||
        role == UserRole.admin ||
        role == UserRole.whMgr;
    final canClose = canApprove;

    final showVerify = status == 'inward_created' && canVerify;
    final showApprove = status == 'verification_pending' && canApprove;
    final showClose = status == 'approved' && canClose;

    if (!showVerify && !showApprove && !showClose) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (showVerify)
              FilledButton.icon(
                onPressed: () => _confirmAndAct(
                  context,
                  title: 'Verify Entry',
                  message: 'Verify this gate entry?',
                  action: () => ref
                      .read(gateEntryControllerProvider.notifier)
                      .verifyEntry(entry.id),
                ),
                icon: const Icon(Icons.verified),
                label: const Text('Verify'),
              ),
            if (showApprove)
              FilledButton.icon(
                onPressed: () => _confirmAndAct(
                  context,
                  title: 'Approve Entry',
                  message: 'Approve this gate entry?',
                  action: () => ref
                      .read(gateEntryControllerProvider.notifier)
                      .approveEntry(entry.id),
                ),
                icon: const Icon(Icons.check_circle),
                label: const Text('Approve'),
              ),
            if (showClose)
              FilledButton.icon(
                onPressed: () => _confirmAndAct(
                  context,
                  title: 'Close Entry',
                  message: 'Close this gate entry?',
                  action: () => ref
                      .read(gateEntryControllerProvider.notifier)
                      .closeEntry(entry.id),
                ),
                icon: const Icon(Icons.lock),
                label: const Text('Close'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndAct(
    BuildContext context, {
    required String title,
    required String message,
    required Future<bool> Function() action,
  }) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (proceed != true) return;
    final success = await action();
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action completed'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      // ignore: unused_result\n      ref.refresh(gateEntryDetailControllerProvider(widget.entryId));
      ref
          .read(gateEntryControllerProvider.notifier)
          .fetchEntries(refresh: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action failed'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }


  Widget _buildItemList(GateEntry entry) {
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
                    .withValues(alpha: 0.5)),
          ),
          child: ListTile(
            title: Text(item.materialCode),
            subtitle: Text('PO: ${item.poNumber} • UOM: ${item.uom}'),
            trailing: Text('Qty ${item.challanQty}'),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildItemTable(BuildContext context, GateEntry entry) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5)),
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

  Widget _infoChip(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}




