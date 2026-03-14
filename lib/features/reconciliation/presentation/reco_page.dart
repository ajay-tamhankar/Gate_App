import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:data_table_2/data_table_2.dart';

import 'controllers/reco_list_controller.dart';
import '../../../core/ui/responsive.dart';
import '../domain/entities/reco_exception.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';

class RecoPage extends ConsumerWidget {
  const RecoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recoListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation Exceptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(recoListControllerProvider.notifier).refresh(),
          ),
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
            child: isMob
                ? _buildMobileList(exceptions, context, ref)
                : _buildDesktopTable(exceptions, context, ref),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Resolved' || status == 'Matched') return Colors.green;
    if (status == 'Quantity Mismatch') return Colors.orange;
    if (status == 'Pending GRN') return Colors.grey;
    // Errors: GRN Not Posted, Duplicate GRN Detected, Wrong PO/Material GRN
    return Colors.red;
  }

  IconData _getStatusIcon(String status) {
    if (status == 'Resolved' || status == 'Matched') return Icons.check_circle;
    if (status == 'Quantity Mismatch') return Icons.warning_amber_rounded;
    if (status == 'Pending GRN') return Icons.hourglass_empty;
    return Icons.error_outline;
  }

  Widget _buildMobileList(
      List<RecoException> exceptions, BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final canResolve =
        role == UserRole.warehouseManager || role == UserRole.admin;

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: exceptions.length,
      itemBuilder: (context, index) {
        final exc = exceptions[index];
        final color = _getStatusColor(exc.status);
        final icon = _getStatusIcon(exc.status);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            title: Text('${exc.poNumber} (Gate Entry: ${exc.gateEntryId})'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(exc.description,
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                    'Opened: ${DateFormat('MMM dd, HH:mm').format(exc.createdAt)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey)),
              ],
            ),
            trailing: Chip(
              label: Text(exc.status,
                  style: TextStyle(color: color.withValues(alpha: 1.0))),
              backgroundColor: color.withValues(alpha: 0.1),
            ),
            isThreeLine: true,
            onTap: () {
              if (!canResolve) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Access Denied. Only Warehouse Managers can resolve exceptions.')),
                );
                return;
              }
              // Navigate to Exception Details for Resolving (to be implemented)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening Resolution Dialog...')),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(
      List<RecoException> exceptions, BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 16,
          minWidth: 1000,
          columns: const [
            DataColumn2(label: Text('Status'), size: ColumnSize.S),
            DataColumn2(label: Text('Gate Entry'), size: ColumnSize.S),
            DataColumn2(label: Text('PO Numb'), size: ColumnSize.S),
            DataColumn2(label: Text('Description'), size: ColumnSize.L),
            DataColumn2(label: Text('Created'), size: ColumnSize.M),
          ],
          rows: exceptions.map((RecoException exc) {
            final color = _getStatusColor(exc.status);
            final icon = _getStatusIcon(exc.status);
            return DataRow(
              cells: [
                DataCell(Row(
                  children: [
                    Icon(icon, color: color, size: 18),
                    const SizedBox(width: 6),
                    Flexible(
                        child: Text(exc.status,
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis)),
                  ],
                )),
                DataCell(Text(exc.gateEntryId,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(exc.poNumber)),
                DataCell(Text(exc.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis)),
                DataCell(
                    Text(DateFormat('MMM dd, y HH:mm').format(exc.createdAt))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
