import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import '../../../core/ui/widgets/status_chip.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../domain/models/warehouse_gate_entry.dart';
import 'controllers/warehouse_providers.dart';
import 'warehouse_gate_entry_detail_page.dart';

class WarehouseGateEntryListPage extends ConsumerWidget {
  const WarehouseGateEntryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(warehouseGateEntriesProvider);
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final isManager =
        role == UserRole.warehouseManager || role == UserRole.whMgr;
    final isMob = isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isManager ? 'Gate Entries' : 'Pending GRNs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(warehouseGateEntriesProvider),
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: entries.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            SkeletonLoader(width: 260, height: 32),
            SizedBox(height: 16),
            SkeletonLoader(width: double.infinity, height: 120),
            SizedBox(height: 12),
            SkeletonLoader(width: double.infinity, height: 120),
          ],
        ),
        error: (e, _) => Center(child: Text('Failed to load entries: $e')),
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Text(isManager ? 'No gate entries found' : 'No pending GRNs'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(warehouseGateEntriesProvider),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMob ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    title: isManager
                        ? 'Warehouse Gate Entries'
                        : 'Gate Entries Pending GRN',
                    subtitle: isManager
                        ? 'Tap an entry to inspect details and approve or close it.'
                        : 'Tap an entry to inspect details and create GRN.',
                    trailing: isMob
                        ? null
                        : Text(
                            'Total: ${data.length}',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: isMob
                        ? _buildMobileList(data)
                        : _buildDesktopTable(context, data),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileList(List<WarehouseGateEntrySummary> entries) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WarehouseGateEntryDetailPage(entryId: entry.id),
              ),
            );
          },
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.gateEntryNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      StatusChip(
                        label: entry.statusLabel,
                        color: _statusColor(entry.statusLabel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Vendor: ${entry.vendorName}'),
                  const SizedBox(height: 6),
                  Text('Vehicle: ${entry.vehicleNo}'),
                  const SizedBox(height: 6),
                  Text(
                    'PO: ${entry.poNumber.isEmpty ? 'N/A' : entry.poNumber}',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Date: ${entry.entryTime != null ? DateFormat('MMM dd, yyyy').format(entry.entryTime!) : 'N/A'}',
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
    List<WarehouseGateEntrySummary> entries,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 24,
          minWidth: 800,
          columns: const [
            DataColumn2(label: Text('Gate Entry No'), size: ColumnSize.M),
            DataColumn2(label: Text('Vendor'), size: ColumnSize.L),
            DataColumn2(label: Text('Vehicle'), size: ColumnSize.M),
            DataColumn2(label: Text('Date'), size: ColumnSize.M),
            DataColumn2(label: Text('Status'), size: ColumnSize.S),
          ],
          rows: entries.map((entry) {
            return DataRow(
              onSelectChanged: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        WarehouseGateEntryDetailPage(entryId: entry.id),
                  ),
                );
              },
              cells: [
                DataCell(Text(entry.gateEntryNo)),
                DataCell(Text(entry.vendorName)),
                DataCell(Text(entry.vehicleNo)),
                DataCell(Text(
                  entry.entryTime != null
                      ? DateFormat('MMM dd, yyyy').format(entry.entryTime!)
                      : 'N/A',
                )),
                DataCell(
                  StatusChip(
                    label: entry.statusLabel,
                    color: _statusColor(entry.statusLabel),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('closed')) return Colors.grey;
    if (normalized.contains('approved')) return Colors.green;
    if (normalized.contains('verified')) return Colors.blue;
    return Colors.orange;
  }
}
