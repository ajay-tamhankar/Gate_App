import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/filter_bar.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import '../../../core/ui/widgets/status_chip.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../domain/models/gate_entry.dart';
import 'controllers/gate_entry_controller.dart';
import 'gate_entry_detail_page.dart';
import 'gate_entry_form_page.dart';

class GateEntryPage extends ConsumerStatefulWidget {
  const GateEntryPage({super.key});

  @override
  ConsumerState<GateEntryPage> createState() => _GateEntryPageState();
}

class _GateEntryPageState extends ConsumerState<GateEntryPage> {
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(gateEntryControllerProvider.notifier)
          .fetchEntries(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gateEntryControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final canCreate = role == UserRole.gateSecurity;
    final isMob = isMobile(context);

    // Client-side filtering
    var filtered = state.entries.where((e) {
      final matchesSearch =
          e.challanNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.vendorName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'All' || e.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Entry Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(gateEntryControllerProvider.notifier)
                .fetchEntries(refresh: true),
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const GateEntryFormPage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Gate Entry'),
            )
          : null,
      body: state.isLoading && state.entries.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                SkeletonLoader(width: double.infinity, height: 80),
                SizedBox(height: 16),
                SkeletonLoader(width: double.infinity, height: 60),
                SizedBox(height: 16),
                SkeletonLoader(width: double.infinity, height: 400),
              ],
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(gateEntryControllerProvider.notifier)
                  .fetchEntries(refresh: true),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // SectionHeader(
                    //   title: 'Inbound & Outbound Log',
                    //   subtitle:
                    //       'Manage and track all gate movements seamlessly.',
                    //   trailing: isMob
                    //       ? null
                    //       : Text('Total: ${filtered.length} entries',
                    //           style: Theme.of(context)
                    //               .textTheme
                    //               .labelLarge
                    //               ?.copyWith(
                    //                   color:
                    //                       Theme.of(context).colorScheme.primary,
                    //                   fontWeight: FontWeight.bold)),
                    // ),
                    const SizedBox(height: 12),
                    FilterBar(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              flex: 2,
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  prefixIcon:
                                      const Icon(Icons.search, size: 18),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onChanged: (val) =>
                                    setState(() => _searchQuery = val),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: DropdownButtonFormField<String>(
                                initialValue: _statusFilter,
                                style: const TextStyle(
                                  fontSize: 10,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Status',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: [
                                  DropdownMenuItem(
                                      value: 'All',
                                      child: Text('All',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ))),
                                  DropdownMenuItem(
                                      value: 'inward_created',
                                      child: Text('Pending',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ))),
                                  DropdownMenuItem(
                                      value: 'verification_pending',
                                      child: Text('Verifying',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ))),
                                  DropdownMenuItem(
                                      value: 'approved',
                                      child: Text('Approved',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ))),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _statusFilter = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (state.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Error: ${state.error}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                  'No gate entries found matching filter.'))
                          : (isMob
                              ? _buildMobileList(filtered)
                              : _buildDesktopTable(filtered)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildMobileList(List<GateEntry> entries) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80), // space for FAB
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isGateIn = entry.gateMovement == GateMovement.inMovement;
        final isPending = entry.status == 'inward_created';
        final materialCode =
            entry.items.isNotEmpty ? entry.items.first.materialCode : 'N/A';
        final qty = entry.items.isNotEmpty
            ? entry.items.fold(0, (sum, i) => sum + i.challanQty)
            : 0;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GateEntryDetailPage(entryId: entry.id),
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
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor:
                                  (isGateIn ? Colors.indigo : Colors.deepOrange)
                                      .withValues(alpha: 0.1),
                              child: Icon(
                                isGateIn ? Icons.login : Icons.logout,
                                color: isGateIn
                                    ? Colors.indigo
                                    : Colors.deepOrange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.challanNo,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(materialCode,
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        StatusChip(
                          label: entry.status,
                          color: isPending ? Colors.orange : Colors.green,
                        ),
                      ],
                    ),
                    if (_shouldShowActionBar(entry.status, role)) ...[
                      const SizedBox(height: 12),
                      _buildActionBar(context, entry, role),
                    ],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Vendor',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12)),
                              Text(entry.vendorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Quantity',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12)),
                              Text('$qty',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ]),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Transporter',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12)),
                              Text(entry.transporterName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ]),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Time',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12)),
                              Text(
                                  entry.gateTimestamp != null
                                      ? DateFormat('MMM dd, yyyy • hh:mm a')
                                          .format(
                                              entry.gateTimestamp!.toLocal())
                                      : 'N/A',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ]),
                      ],
                    )
                  ]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(List<GateEntry> entries) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
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
          dataRowHeight: 64,
          columns: const [
            DataColumn2(label: Text('Direction'), size: ColumnSize.S),
            DataColumn2(label: Text('Challan No'), size: ColumnSize.M),
            DataColumn2(label: Text('Material'), size: ColumnSize.S),
            DataColumn2(label: Text('Qty'), size: ColumnSize.S, numeric: true),
            DataColumn2(label: Text('Vendor'), size: ColumnSize.L),
            DataColumn2(label: Text('Transporter'), size: ColumnSize.L),
            DataColumn2(label: Text('Entry Time'), size: ColumnSize.M),
            DataColumn2(label: Text('Status'), size: ColumnSize.S),
            DataColumn2(label: Text('Actions'), size: ColumnSize.S),
          ],
          rows: entries.map((entry) {
            final isGateIn = entry.gateMovement == GateMovement.inMovement;
            final isPending = entry.status == 'inward_created';
            final materialCode =
                entry.items.isNotEmpty ? entry.items.first.materialCode : '-';
            final qty = entry.items.isNotEmpty
                ? entry.items.fold(0, (sum, i) => sum + i.challanQty)
                : 0;

            return DataRow(
              onSelectChanged: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GateEntryDetailPage(entryId: entry.id),
                  ),
                );
              },
              cells: [
                DataCell(Row(
                  children: [
                    Icon(isGateIn ? Icons.login : Icons.logout,
                        size: 18,
                        color: isGateIn ? Colors.indigo : Colors.deepOrange),
                    const SizedBox(width: 8),
                    Text(isGateIn ? 'Gate In' : 'Gate Out',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                )),
                DataCell(Text(entry.challanNo,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(materialCode)),
                DataCell(Text(qty.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(entry.vendorName)),
                DataCell(Text(entry.transporterName)),
                DataCell(
                  Text(
                    entry.gateTimestamp != null
                        ? DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(entry.gateTimestamp!.toLocal())
                        : '-',
                  ),
                ),
                DataCell(
                  StatusChip(
                    label: entry.status,
                    color: isPending ? Colors.orange : Colors.green,
                  ),
                ),
                DataCell(_buildActionBar(context, entry, role)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  bool _shouldShowActionBar(String status, UserRole? role) {
    final canVerify =
        role == UserRole.warehouseExecutive || role == UserRole.admin;
    final canApprove = role == UserRole.warehouseManager ||
        role == UserRole.admin ||
        role == UserRole.whMgr;
    final canClose = canApprove;

    final showVerify = status == 'inward_created' && canVerify;
    final showApprove = status == 'verification_pending' && canApprove;
    final showClose = status == 'approved' && canClose;

    return showVerify || showApprove || showClose;
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

    return Wrap(
      spacing: 8,
      children: [
        if (showVerify)
          FilledButton.tonal(
            onPressed: () => _confirmAndAct(
              context,
              title: 'Verify Entry',
              message: 'Verify this gate entry?',
              action: () => ref
                  .read(gateEntryControllerProvider.notifier)
                  .verifyEntry(entry.id),
            ),
            child: const Text('Verify'),
          ),
        if (showApprove)
          FilledButton.tonal(
            onPressed: () => _confirmAndAct(
              context,
              title: 'Approve Entry',
              message: 'Approve this gate entry?',
              action: () => ref
                  .read(gateEntryControllerProvider.notifier)
                  .approveEntry(entry.id),
            ),
            child: const Text('Approve'),
          ),
        if (showClose)
          FilledButton.tonal(
            onPressed: () => _confirmAndAct(
              context,
              title: 'Close Entry',
              message: 'Close this gate entry?',
              action: () => ref
                  .read(gateEntryControllerProvider.notifier)
                  .closeEntry(entry.id),
            ),
            child: const Text('Close'),
          ),
      ],
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
}
