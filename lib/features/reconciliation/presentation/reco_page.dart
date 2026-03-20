import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/status_chip.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../domain/entities/reco_exception.dart';
import 'controllers/reco_list_controller.dart';
import '../domain/usecases/import_sap_grns.dart';
import 'controllers/import_history_controller.dart';
import 'reco_exception_detail_page.dart';
import 'reconciliation_security_view.dart';

class RecoPage extends ConsumerWidget {
  const RecoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recoListControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    if (role == UserRole.gateSecurity) {
      return const ReconciliationSecurityView();
    }
    final canImport =
        role == UserRole.warehouseManager || role == UserRole.admin;
    final importHistory = ref.watch(importHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation Exceptions'),
        actions: [
          if (canImport)
            TextButton.icon(
              onPressed: () => _importSap(context, ref),
              icon: const Icon(Icons.upload_file),
              label: const Text('Import SAP GRNs'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(recoListControllerProvider.notifier).refresh(),
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
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
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SectionHeader(
                          title: 'Actionable Exceptions',
                          subtitle:
                              'Resolve discrepancies between Gate Entries and SAP GRNs.',
                          trailing: isMob
                              ? null
                              : Text('${exceptions.length} Items Pending',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error)),
                        ),
                        if (importHistory.isNotEmpty)
                          _buildImportHistory(context, importHistory),
                        if (importHistory.isNotEmpty)
                          const SizedBox(height: 16),
                        Expanded(
                            child: isMob
                                ? _buildMobileList(exceptions, context, ref)
                                : _buildDesktopTable(exceptions, context, ref)),
                      ])));
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Resolved' || status == 'Matched') {
      return const Color(0xFF16A34A); // Green
    }
    if (status == 'Quantity Mismatch') return const Color(0xFFF59E0B); // Amber
    if (status == 'Pending GRN') return Colors.grey;
    return const Color(0xFFDC2626); // Red (Duplicate, Wrong PO)
  }

  IconData _getStatusIcon(String status) {
    if (status == 'Resolved' || status == 'Matched') return Icons.check_circle;
    if (status == 'Quantity Mismatch') return Icons.warning_amber_rounded;
    if (status == 'Pending GRN') return Icons.hourglass_empty;
    return Icons.error_outline;
  }

  Future<void> _importSap(BuildContext context, WidgetRef ref) async {
    final fileResult = await ref
        .read(importSapGrnsUseCaseProvider)
        .pickFile();

    if (fileResult == null) return;

    final response = await ref
        .read(importSapGrnsUseCaseProvider)
        .execute(fileResult);

    ref.read(importHistoryProvider.notifier).addItem(
          ImportHistoryItem(
            timestamp: DateTime.now(),
            fileName: fileResult.name,
            success: response.success,
            message: response.message.isNotEmpty
                ? response.message
                : (response.success ? 'Import completed' : 'Import failed'),
          ),
        );

    if (context.mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty
                ? response.message
                : 'SAP GRNs imported'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        await ref.read(recoListControllerProvider.notifier).refresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty
                ? response.message
                : 'Import failed'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<String?> _showResolveDialog(
      BuildContext context, RecoException exc) async {
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
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
    return result != null && result.isNotEmpty ? result : null;
  }

  Widget _buildMobileList(
      List<RecoException> exceptions, BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final canResolve =
        role == UserRole.warehouseManager || role == UserRole.admin;

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: exceptions.length,
      itemBuilder: (context, index) {
        final exc = exceptions[index];
        final color = _getStatusColor(exc.status);
        final icon = _getStatusIcon(exc.status);

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    RecoExceptionDetailPage(exceptionId: exc.id),
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
                    Text('Gate Entry: ${exc.gateEntryId}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    StatusChip(label: exc.status, color: color, icon: icon),
                  ],
                ),
                const SizedBox(height: 12),
                Text('PO No: ${exc.poNumber}',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(exc.description,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM dd, HH:mm').format(exc.createdAt),
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12)),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onPressed: () async {
                        if (!canResolve) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Access Denied. Mgr required.')));
                          return;
                        }
                        final notes =
                            await _showResolveDialog(context, exc);
                        if (notes == null) return;
                        await ref
                            .read(recoListControllerProvider.notifier)
                            .resolveException(exc.id, notes);
                      },
                      child: const Text('Resolve'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
      },
    );
  }

  Widget _buildDesktopTable(
      List<RecoException> exceptions, BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final canResolve =
        role == UserRole.warehouseManager || role == UserRole.admin;

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
          dataRowHeight: 68,
          columns: const [
            DataColumn2(label: Text('Status'), size: ColumnSize.L),
            DataColumn2(label: Text('Gate Entry'), size: ColumnSize.S),
            DataColumn2(label: Text('PO Number'), size: ColumnSize.M),
            DataColumn2(label: Text('Description'), size: ColumnSize.L),
            DataColumn2(label: Text('Created'), size: ColumnSize.M),
            DataColumn2(label: Text('Action'), size: ColumnSize.S),
          ],
          rows: exceptions.map((RecoException exc) {
            final color = _getStatusColor(exc.status);
            final icon = _getStatusIcon(exc.status);
            return DataRow(
              onSelectChanged: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        RecoExceptionDetailPage(exceptionId: exc.id),
                  ),
                );
              },
              cells: [
                DataCell(
                    StatusChip(label: exc.status, color: color, icon: icon)),
                DataCell(Text(exc.gateEntryId,
                    style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(Text(exc.poNumber)),
                DataCell(Text(exc.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis)),
                DataCell(
                    Text(DateFormat('MMM dd, y HH:mm').format(exc.createdAt))),
                DataCell(FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () async {
                    if (!canResolve) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Access Denied. Mgr Required.')));
                      return;
                    }
                    final notes = await _showResolveDialog(context, exc);
                    if (notes == null) return;
                    await ref
                        .read(recoListControllerProvider.notifier)
                        .resolveException(exc.id, notes);
                  },
                  child: const Text('Resolve'),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildImportHistory(
      BuildContext context, List<ImportHistoryItem> history) {
    return Card(
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import History',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...history.take(5).map((item) {
              final time =
                  DateFormat('MMM dd, HH:mm').format(item.timestamp);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  item.success ? Icons.check_circle : Icons.error,
                  color: item.success ? Colors.green : Colors.redAccent,
                ),
                title: Text(item.fileName),
                subtitle: Text('$time • ${item.message}'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
