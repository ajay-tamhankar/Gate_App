import 'package:data_table_2/data_table_2.dart';
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
import 'warehouse_reconciliation_detail_page.dart';

class WarehouseReconciliationListPage extends ConsumerWidget {
  const WarehouseReconciliationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final isManager =
        role == UserRole.warehouseManager || role == UserRole.whMgr;
    final items = ref.watch(warehouseManagerReconciliationsProvider);
    final isMob = isMobile(context);

    if (!isManager) {
      return const Scaffold(
        body: Center(child: Text('Warehouse Manager access required.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(warehouseManagerReconciliationsProvider);
              ref.invalidate(warehouseManagerDashboardSummaryProvider);
            },
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: items.when(
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
        error: (e, _) =>
            Center(child: Text('Failed to load reconciliations: $e')),
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('No active reconciliations found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(warehouseManagerReconciliationsProvider);
              ref.invalidate(warehouseManagerDashboardSummaryProvider);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMob ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    title: 'Manager Approval Queue',
                    subtitle:
                        'Review matched and exception reconciliations before final closure.',
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
                        ? _buildMobileList(context, data)
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

  Widget _buildMobileList(
    BuildContext context,
    List<WarehouseReconciliationRecord> items,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => _openDetail(context, item),
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
                      'Vendor: ${item.vendorName.isEmpty ? 'N/A' : item.vendorName}'),
                  const SizedBox(height: 6),
                  Text('PO: ${item.poNumber.isEmpty ? 'N/A' : item.poNumber}'),
                  const SizedBox(height: 6),
                  Text(
                    'Date: ${item.date != null ? DateFormat('MMM dd, yyyy • hh:mm a').format(item.date!) : 'N/A'}',
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
          minWidth: 900,
          columns: const [
            DataColumn2(label: Text('Gate Entry No'), size: ColumnSize.M),
            DataColumn2(label: Text('Vendor'), size: ColumnSize.L),
            DataColumn2(label: Text('PO Number'), size: ColumnSize.M),
            DataColumn2(label: Text('Status'), size: ColumnSize.S),
            DataColumn2(label: Text('Date'), size: ColumnSize.M),
          ],
          rows: items.map((item) {
            return DataRow(
              onSelectChanged: (_) => _openDetail(context, item),
              cells: [
                DataCell(Text(
                    item.gateEntryNo.isEmpty ? item.id : item.gateEntryNo)),
                DataCell(
                    Text(item.vendorName.isEmpty ? 'N/A' : item.vendorName)),
                DataCell(Text(item.poNumber.isEmpty ? 'N/A' : item.poNumber)),
                DataCell(_statusChip(item)),
                DataCell(Text(
                  item.date != null
                      ? DateFormat('MMM dd, yyyy • hh:mm a').format(item.date!)
                      : 'N/A',
                )),
              ],
            );
          }).toList(),
        ),
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
    return const StatusChip(label: 'Pending', color: Colors.orange);
  }

  void _openDetail(BuildContext context, WarehouseReconciliationRecord item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WarehouseReconciliationDetailPage(record: item),
      ),
    );
  }
}
