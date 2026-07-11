import 'dart:async';

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
import '../domain/reconciliation_period_filter.dart';
import 'controllers/reco_list_controller.dart';
import '../domain/usecases/import_sap_grns.dart';
import 'controllers/import_history_controller.dart';
import 'reco_exception_detail_page.dart';
import 'reconciliation_security_view.dart';

import '../../gate_entry/presentation/gate_entry_detail_page.dart';
import '../../warehouse/domain/models/warehouse_reconciliation.dart';
import '../../warehouse/presentation/controllers/warehouse_providers.dart';
import '../../warehouse/presentation/controllers/warehouse_reconciliation_list_controller.dart';
import '../../../core/ui/widgets/filter_bar.dart';
import '../../../core/ui/widgets/progress_dialog.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';

// Shared DateFormat instances. Constructing DateFormat is expensive (it
// parses the pattern + allocates intl symbols), so reusing one instance
// across every row save ~10-40µs/row and a noticeable chunk of frame time
// on large tables.
final DateFormat _kListDateFormat = DateFormat('MMM dd, yyyy - hh:mm a');
final DateFormat _kShortDateFormat = DateFormat('MMM dd, yyyy');

class RecoPage extends ConsumerWidget {
  const RecoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    
    if (role == UserRole.gateSecurity) {
      return const ReconciliationSecurityView();
    }
    
    if (role.isAdminOrWarehouseManager) {
      return const _WarehouseReconciliationView();
    }
    
    return const _RecoOperationsView();
  }
}

class _RecoOperationsView extends ConsumerWidget {
  const _RecoOperationsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recoListControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    if (role == UserRole.gateSecurity) {
      return const ReconciliationSecurityView();
    }
    final canImport =
        role.isAdminOrWarehouseManager;
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
        loading: () => _buildListSkeleton(),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildListSkeleton() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SkeletonLoader(width: 240, height: 24),
          SizedBox(height: 8),
          SkeletonLoader(width: 320, height: 16),
          SizedBox(height: 24),
          SkeletonLoader(width: double.infinity, height: 72),
          SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 72),
          SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 72),
          SizedBox(height: 12),
          SkeletonLoader(width: double.infinity, height: 72),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    final key = status.toLowerCase();
    if (key == 'resolved' || key == 'matched') {
      return const Color(0xFF16A34A); // Green
    }
    if (key.contains('quantity') && key.contains('mismatch')) {
      return const Color(0xFFF59E0B); // Amber
    }
    if (key.contains('pending') ||
        key.contains('not_posted') ||
        key.contains('missing')) {
      return Colors.grey;
    }
    return const Color(0xFFDC2626); // Red (Duplicate, Wrong PO)
  }

  IconData _getStatusIcon(String status) {
    final key = status.toLowerCase();
    if (key == 'resolved' || key == 'matched') {
      return Icons.check_circle;
    }
    if (key.contains('quantity') && key.contains('mismatch')) {
      return Icons.warning_amber_rounded;
    }
    if (key.contains('pending') ||
        key.contains('not_posted') ||
        key.contains('missing')) {
      return Icons.hourglass_empty;
    }
    return Icons.error_outline;
  }

  Future<void> _importSap(BuildContext context, WidgetRef ref) async {
    final fileResult = await ref.read(importSapGrnsUseCaseProvider).pickFile();
    if (fileResult == null) return;

    if (!context.mounted) return;

    // Simple confirmation — no date options needed, reconciliation is automatic
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import GRN Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('File: ${fileResult.name}'),
            const SizedBox(height: 12),
            const Text(
              'GRN records will be imported immediately. Reconciliation will run in the background.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Import GRNs'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final response = await runWithProgressDialog(
      context,
      () => ref.read(importSapGrnsUseCaseProvider).execute(fileResult),
      label: 'Uploading ${fileResult.name}...',
    );

    if (!context.mounted) return;

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
        final result = response.data;
        final imported = result?.importedCount ?? result?.processed ?? 0;
        final msg = imported > 0
            ? 'Import complete, reconciliation running in background. Imported $imported GRN records.'
            : 'Import complete, reconciliation running in background.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        await ref.read(recoListControllerProvider.notifier).refresh();
        ref.invalidate(warehouseManagerReconciliationsProvider);
        ref.invalidate(reconciliationDashboardProvider);
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
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
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
        role.isAdminOrWarehouseManager;

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
                  builder: (_) => RecoExceptionDetailPage(exceptionId: exc.id),
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
                        Text('Gate Entry No: ${exc.gateEntryId}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        StatusChip(label: exc.status, color: color, icon: icon),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Matched GRN: ${exc.poNumber}',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(exc.description,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            _kListDateFormat.format(exc.createdAt),
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
                                      content: Text(
                                          'Access Denied. Mgr required.')));
                              return;
                            }
                            final notes =
                                await _showResolveDialog(context, exc);
                            if (notes == null) return;
                            if (!context.mounted) return;
                            await runWithProgressDialog(
                              context,
                              () => ref
                                  .read(recoListControllerProvider.notifier)
                                  .resolveException(exc.id, notes),
                              label: 'Resolving exception...',
                            );
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
        role.isAdminOrWarehouseManager;

    // Materialising thousands of DataRow widgets in one frame was the largest
    // single jank source on this screen. Use the same 200-row cap the
    // warehouse reconciliation view already uses; users see a banner when
    // the data is truncated so they know to filter.
    const maxDisplayedRows = 200;
    final visible = exceptions.length > maxDisplayedRows
        ? exceptions.sublist(0, maxDisplayedRows)
        : exceptions;
    final truncated = exceptions.length - visible.length;

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
        child: Column(
          children: [
            if (truncated > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Text(
                  'Showing first $maxDisplayedRows of ${exceptions.length}. Apply filters to narrow the list.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            Expanded(
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 24,
                minWidth: 1000,
                headingRowHeight: 56,
                dataRowHeight: 68,
                columns: const [
                  DataColumn2(label: Text('Status'), size: ColumnSize.L),
                  DataColumn2(label: Text('Gate Entry'), size: ColumnSize.S),
                  DataColumn2(label: Text('Matched GRN'), size: ColumnSize.M),
                  DataColumn2(label: Text('Description'), size: ColumnSize.L),
                  DataColumn2(label: Text('Reconciled At'), size: ColumnSize.M),
                  DataColumn2(label: Text('Action'), size: ColumnSize.S),
                ],
                rows: visible.map((RecoException exc) {
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
                      DataCell(StatusChip(
                          label: exc.status, color: color, icon: icon)),
                      DataCell(Text(exc.gateEntryId,
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(exc.poNumber)),
                      DataCell(Text(exc.description,
                          maxLines: 2, overflow: TextOverflow.ellipsis)),
                      DataCell(Text(_kListDateFormat.format(exc.createdAt))),
                      DataCell(FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: () async {
                          if (!canResolve) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Access Denied. Mgr Required.')));
                            return;
                          }
                          final notes = await _showResolveDialog(context, exc);
                          if (notes == null) return;
                          if (!context.mounted) return;
                          await runWithProgressDialog(
                            context,
                            () => ref
                                .read(recoListControllerProvider.notifier)
                                .resolveException(exc.id, notes),
                            label: 'Resolving exception...',
                          );
                        },
                        child: const Text('Resolve'),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
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
              final time = _kListDateFormat.format(item.timestamp);
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  item.success ? Icons.check_circle : Icons.error,
                  color: item.success ? Colors.green : Colors.redAccent,
                ),
                title: Text(item.fileName),
                subtitle: Text('$time - ${item.message}'),
              );
            }),
          ],
        ),
      ),
    );
  }
}





// ---------------------------------------------------------------------------
// WAREHOUSE RECO VIEW (merged from warehouse_reconciliation_list_page.dart)
// ---------------------------------------------------------------------------

class _WarehouseReconciliationView extends ConsumerStatefulWidget {
  const _WarehouseReconciliationView();

  @override
  ConsumerState<_WarehouseReconciliationView> createState() =>
      __WarehouseReconciliationViewState();
}

class __WarehouseReconciliationViewState
    extends ConsumerState<_WarehouseReconciliationView> {
  String _searchQuery = '';
  String _statusFilter = 'All';
  ReconciliationPeriodFilter _periodFilter = ReconciliationPeriodFilter.all;
  bool _hasExplicitPeriodSelection = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _isSearching = false;

  // Memoized filter result. _applyFilters walks up to ~1.4k records and is
  // re-invoked on every parent rebuild (search keystroke, spinner toggle,
  // status chip tap). Caching by identity-of-items + search + status avoids
  // redoing the same work when only an unrelated bit of state flipped.
  List<WarehouseReconciliationRecord>? _cachedFiltered;
  Object? _cachedItemsRef;
  String? _cachedSearch;
  String? _cachedStatus;

  // DataTable2 with hundreds of materialized DataRow widgets is the dominant
  // render cost. Capping the visible rows keeps the page snappy; the count
  // chip still reflects the true match total so the user knows it's truncated.
  static const int _maxDisplayedRows = 200;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    if (value != _searchController.text) {
      _searchController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    setState(() {
      _searchQuery = value;
      _isSearching = true;
    });
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _runServerSearch(value.trim());
    });
  }

  Future<void> _runServerSearch(String text) async {
    await ref
        .read(warehouseReconciliationListControllerProvider.notifier)
        .refresh(search: text);
    if (mounted) setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final isManager =
        role == UserRole.warehouseManager || role == UserRole.whMgr || role == UserRole.admin;
    final state = ref.watch(warehouseReconciliationListControllerProvider);
    final isMob = isMobile(context);
    final isTab = isTablet(context);

    if (!isManager) {
      return const Scaffold(
        body: Center(child: Text('Manager/Admin access required.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await ref
                  .read(warehouseReconciliationListControllerProvider.notifier)
                  .refresh(filter: _periodFilter);
              ref.invalidate(warehouseManagerDashboardSummaryProvider);
            },
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading && state.items.isEmpty
          ? _buildLoadingView(isMob, isTab)
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(warehouseReconciliationListControllerProvider.notifier)
                    .refresh(filter: _periodFilter);
                ref.invalidate(warehouseManagerDashboardSummaryProvider);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentWidth = constraints.maxWidth > 1440
                      ? 1440.0
                      : constraints.maxWidth;
                  final filtered = _applyFilters(state.items);

                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: contentWidth,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMob ? 16 : 24,
                          vertical: isMob ? 16 : 24,
                        ),
                        children: [
                          _buildSummarySection(context, state, isMob, isTab),
                          const SizedBox(height: 16),
                          _buildFilters(context, filtered.length, isMob),
                          const SizedBox(height: 16),
                          if (state.error != null) ...[
                            _buildErrorBanner(context, state.error!),
                            const SizedBox(height: 16),
                          ],
                          // The new API embeds synthetic pending-GRN and
                          // orphan-GRN rows directly inside `data`, so empty
                          // filtered list = nothing to render in any case.
                          if (filtered.isEmpty)
                            _buildEmptyState(context)
                          else ...[
                            isMob
                                ? _buildMobileList(
                                    context,
                                    filtered.length > _maxDisplayedRows
                                        ? filtered.sublist(
                                            0, _maxDisplayedRows)
                                        : filtered,
                                  )
                                : _buildDesktopTable(
                                    context,
                                    filtered.length > _maxDisplayedRows
                                        ? filtered.sublist(
                                            0, _maxDisplayedRows)
                                        : filtered,
                                    isTab,
                                  ),
                            if (filtered.length > _maxDisplayedRows) ...[
                              const SizedBox(height: 12),
                              _buildTruncatedBanner(
                                  context, filtered.length),
                            ],
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  List<WarehouseReconciliationRecord> _applyFilters(
    List<WarehouseReconciliationRecord> items,
  ) {
    // Cheap cache: re-using the same list of items + same search + same status
    // returns the previous result without walking the list again. Saves us
    // from re-filtering when only the search-spinner flag flips.
    if (identical(_cachedItemsRef, items) &&
        _cachedSearch == _searchQuery &&
        _cachedStatus == _statusFilter &&
        _cachedFiltered != null) {
      return _cachedFiltered!;
    }

    final query = _searchQuery.trim().toLowerCase();
    final result = items.where((item) {
      final matchesSearch = query.isEmpty ||
          item.challanNo.toLowerCase().contains(query) ||
          (item.gateEntryId?.toLowerCase().contains(query) ?? false) ||
          (item.gateEntryNo?.toLowerCase().contains(query) ?? false) ||
          item.displayReason.toLowerCase().contains(query) ||
          item.reasonCode.toLowerCase().contains(query) ||
          item.matchedGrnNumber.toLowerCase().contains(query) ||
          item.displayStatus.toLowerCase().contains(query) ||
          item.vendorName.toLowerCase().contains(query) ||
          item.grnNumber.toLowerCase().contains(query);

      final matchesStatus = switch (_statusFilter) {
        'Matched' => item.isMatched,
        'Pending GRN' => item.normalizedStatus == 'pending_grn',
        'GRN Not Posted' => item.normalizedStatus == 'grn_not_posted',
        'Quantity Mismatch' => item.normalizedStatus == 'quantity_mismatch',
        'Duplicate GRN' => item.normalizedStatus == 'duplicate_grn',
        'Wrong PO/Material' => item.normalizedStatus == 'wrong_po_material',
        'Pending Gate Entry' => item.isPendingGateEntry,
        'Resolved' => item.isResolved,
        'Open' => !item.isResolved,
        _ => true,
      };
      return matchesSearch && matchesStatus;
    }).toList();

    _cachedItemsRef = items;
    _cachedSearch = _searchQuery;
    _cachedStatus = _statusFilter;
    _cachedFiltered = result;
    return result;
  }

  Widget _buildSummarySection(
    BuildContext context,
    WarehouseReconciliationListState state,
    bool isMob,
    bool isTab,
  ) {
    // Counters are sourced from the server-side
    // `reconciliation.summary.gateEntries.byStatus` breakdown (true totals for
    // the active period, independent of the visible-row cap and any local
    // search). Orphan count comes from `reconciliation.summary.orphanGrns`.
    final breakdown = state.statusBreakdown;
    final cards = [
      _summaryCard(
        context,
        title: 'Matched',
        value: '${breakdown.matched}',
        subtitle: 'GRN posted',
        icon: Icons.check_circle,
        accent: Colors.green,
      ),
      _summaryCard(
        context,
        title: 'Pending GRN',
        value: '${breakdown.pendingGrn}',
        subtitle: 'Awaiting SAP GRN',
        icon: Icons.hourglass_top,
        accent: Colors.amber.shade700,
      ),
      _summaryCard(
        context,
        title: 'Exceptions',
        value: '${breakdown.totalExceptions}',
        subtitle: 'Need review',
        icon: Icons.error_outline,
        accent: Colors.red,
      ),
      _summaryCard(
        context,
        title: 'Pending Gate Entry',
        value: '${state.orphanGrnCount}',
        subtitle: 'Orphan GRN',
        icon: Icons.upload_file,
        accent: Colors.amber.shade700,
      ),
    ];

    if (isMob) {
      // Two rows of two cards each so the orphan/pending-grn counts are
      // visible on mobile too.
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 10),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 10),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: cards[0]),
        SizedBox(width: isTab ? 10 : 12),
        Expanded(child: cards[1]),
        SizedBox(width: isTab ? 10 : 12),
        Expanded(child: cards[2]),
        SizedBox(width: isTab ? 10 : 12),
        Expanded(child: cards[3]),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, int count, bool isMob) {
    return FilterBar(
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count records',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final period in ReconciliationPeriodFilter.values)
              ChoiceChip(
                label: Text(period.label),
                selected:
                    _hasExplicitPeriodSelection && _periodFilter == period,
                onSelected: (_) async {
                  if (_hasExplicitPeriodSelection && _periodFilter == period) {
                    return;
                  }
                  setState(() {
                    _periodFilter = period;
                    _hasExplicitPeriodSelection = true;
                  });
                  await ref
                      .read(warehouseReconciliationListControllerProvider.notifier)
                      .refresh(filter: period);
                  ref.invalidate(warehouseManagerDashboardSummaryProvider);
                },
              ),
          ],
        ),
        SizedBox(
          width: isMob ? double.infinity : 320,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search challan, gate entry no, GRN, reason, status',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : (_searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: 'Clear search',
                          onPressed: () => _onSearchChanged(''),
                        )
                      : null),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        SizedBox(
          width: isMob ? double.infinity : 220,
          child: DropdownButtonFormField<String>(
            initialValue: _statusFilter,
            decoration: InputDecoration(
              labelText: 'Filter',
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Matched', child: Text('Matched')),
              DropdownMenuItem(
                  value: 'Pending GRN', child: Text('Pending GRN')),
              DropdownMenuItem(
                  value: 'GRN Not Posted', child: Text('GRN Not Posted')),
              DropdownMenuItem(
                  value: 'Quantity Mismatch',
                  child: Text('Quantity Mismatch')),
              DropdownMenuItem(
                  value: 'Duplicate GRN', child: Text('Duplicate GRN')),
              DropdownMenuItem(
                  value: 'Wrong PO/Material',
                  child: Text('Wrong PO/Material')),
              DropdownMenuItem(
                  value: 'Pending Gate Entry',
                  child: Text('Pending Gate Entry')),
              DropdownMenuItem(value: 'Resolved', child: Text('Resolved')),
              DropdownMenuItem(value: 'Open', child: Text('Open')),
            ],
            onChanged: (val) async {
              if (val == null) return;
              setState(() => _statusFilter = val);
              // Mirror the chosen filter to the server when it maps to one
              // of the seven backend status keys; Resolved/Open/All keep the
              // server query untouched and rely on local filtering.
              await ref
                  .read(warehouseReconciliationListControllerProvider
                      .notifier)
                  .refresh(statusFilter: _serverStatusForDropdown(val));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView(bool isMob, bool isTab) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? 16 : 24,
        vertical: isMob ? 16 : 24,
      ),
      children: [
        const SkeletonLoader(width: double.infinity, height: 150),
        const SizedBox(height: 16),
        if (isMob)
          const SkeletonLoader(width: double.infinity, height: 88)
        else
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 82 : 92,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 82 : 92,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 82 : 92,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 82 : 92,
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        const SkeletonLoader(width: double.infinity, height: 88),
        const SizedBox(height: 16),
        const SkeletonLoader(width: double.infinity, height: 420),
      ],
    );
  }

  Widget _buildMobileList(
    BuildContext context,
    List<WarehouseReconciliationRecord> items,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final color = _statusColor(item);
        return InkWell(
          onTap: () => _openDetail(context, item),
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: color.withValues(alpha: 0.4),
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
                          _rowDisplayId(item),
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
                    item.displayReason.isEmpty ? 'Reason: -' : 'Reason: ${item.displayReason}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Matched GRN: ${item.matchedGrnNumber.isEmpty ? '-' : item.matchedGrnNumber}',
                  ),
                  const SizedBox(height: 6),
                  Text('Qty Variance: ${item.qtyVariance}'),
                  const SizedBox(height: 6),
                  Text(
                    'Date: ${item.date != null ? _kListDateFormat.format(item.date!) : 'N/A'}',
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
    bool isTab,
  ) {
    return SizedBox(
      height: 560,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: DataTable2(
            columnSpacing: isTab ? 10 : 14,
            horizontalMargin: isTab ? 16 : 24,
            minWidth: 1260,
            headingRowHeight: 60,
            dataRowHeight: 68,
            showCheckboxColumn: false,
            columns: const [
              DataColumn2(label: Text('Gate Entry No'), size: ColumnSize.M),
              // Bumped from S to M: the seven status labels now include
              // "Wrong PO/Material" + "Pending Gate Entry" + the chip icon,
              // which together don't fit in the previous narrow column.
              DataColumn2(label: Text('Status'), size: ColumnSize.M),
              DataColumn2(label: Text('Reason'), size: ColumnSize.L),
              DataColumn2(label: Text('Qty Variance'), size: ColumnSize.S),
              DataColumn2(label: Text('Matched GRN'), size: ColumnSize.M),
              DataColumn2(label: Text('Date'), size: ColumnSize.M),
              DataColumn2(label: Text('Resolution'), size: ColumnSize.M),
            ],
            rows: items.map((item) {
              return DataRow(
                onSelectChanged: (_) => _openDetail(context, item),
                cells: [
                  DataCell(Text(
                    _rowDisplayId(item),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  )),
                  DataCell(_statusChip(item)),
                  DataCell(SizedBox(
                    width: 280,
                    child: Text(
                      item.displayReason.isEmpty ? '-' : item.displayReason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )),
                  DataCell(Text(item.qtyVariance.toString())),
                  DataCell(Text(
                    item.matchedGrnNumber.isEmpty ? '-' : item.matchedGrnNumber,
                  )),
                  DataCell(Text(
                    item.date != null
                        ? _kListDateFormat.format(item.date!)
                        : 'N/A',
                  )),
                  DataCell(Text(item.isResolved ? 'Resolved' : 'Open')),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.rule_folder_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No reconciliations found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try changing search text or filter to see more records.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  /// Map the dropdown's display value to the backend `status` key the API
  /// accepts on `GET /reconciliations?status=...`. Returns null for the
  /// pseudo-buckets that have no direct server-side equivalent (All / Resolved
  /// / Open) — those are filtered client-side.
  String? _serverStatusForDropdown(String value) {
    switch (value) {
      case 'Matched':
        return 'matched';
      case 'Pending GRN':
        return 'pending_grn';
      case 'GRN Not Posted':
        return 'grn_not_posted';
      case 'Quantity Mismatch':
        return 'quantity_mismatch';
      case 'Duplicate GRN':
        return 'duplicate_grn';
      case 'Wrong PO/Material':
        return 'wrong_po_material';
      case 'Pending Gate Entry':
        return 'pending_gate_entry';
      default:
        return null;
    }
  }

  /// Best-effort display label for a row's id column.
  /// - Real / pending-GRN rows: prefer `gateEntryNo`, fall back to `id`.
  /// - Orphan GRN rows: show the GRN number so the row is identifiable.
  String _rowDisplayId(WarehouseReconciliationRecord item) {
    final ge = item.gateEntryNo;
    if (ge != null && ge.isNotEmpty) return ge;
    if (item.isPendingGateEntry) {
      if (item.grnNumber.isNotEmpty) return 'GRN ${item.grnNumber}';
    }
    return item.id;
  }

  Widget _statusChip(WarehouseReconciliationRecord item) {
    return StatusChip(
      label: item.displayStatus,
      color: _statusColor(item),
      icon: _statusIcon(item),
    );
  }

  /// Color mapping for each of the seven backend status keys.
  ///   matched              → green   (good)
  ///   pending_grn          → amber   (waiting for SAP GRN — neutral, not bad)
  ///   pending_gate_entry   → amber   (orphan GRN — same "waiting" tone)
  ///   grn_not_posted       → red     (past SLA, real exception)
  ///   quantity_mismatch    → orange  (exception)
  ///   duplicate_grn        → deep-orange (exception)
  ///   wrong_po_material    → indigo  (exception, distinct hue)
  /// Resolved rows show blue regardless of original status.
  Color _statusColor(WarehouseReconciliationRecord item) {
    if (item.isResolved) return Colors.blue;
    switch (item.normalizedStatus) {
      case 'matched':
        return Colors.green;
      case 'pending_grn':
      case 'pending_gate_entry':
        return Colors.amber.shade700;
      case 'grn_not_posted':
        return Colors.red;
      case 'quantity_mismatch':
        return Colors.orange;
      case 'duplicate_grn':
        return Colors.deepOrange;
      case 'wrong_po_material':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(WarehouseReconciliationRecord item) {
    if (item.isResolved) return Icons.verified;
    switch (item.normalizedStatus) {
      case 'matched':
        return Icons.check_circle;
      case 'pending_grn':
        // Gate entry is waiting for its GRN to be uploaded.
        return Icons.hourglass_top;
      case 'pending_gate_entry':
        // GRN is waiting for a matching gate entry — inverse-arrow icon
        // visually distinguishes it from the pending_grn case.
        return Icons.upload_file;
      case 'grn_not_posted':
        return Icons.hourglass_empty;
      case 'quantity_mismatch':
        return Icons.warning_amber_rounded;
      case 'duplicate_grn':
        return Icons.copy_all;
      case 'wrong_po_material':
        return Icons.swap_horiz;
      default:
        return Icons.error_outline;
    }
  }

  Widget _buildErrorBanner(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        error,
        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
      ),
    );
  }

  Widget _buildTruncatedBanner(BuildContext context, int totalMatches) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primary
            .withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing first $_maxDisplayedRows of $totalMatches matches. '
              'Refine your search or filter to narrow the results.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, WarehouseReconciliationRecord item) {
    // Real reconciliation rows → the reconciliation detail screen.
    // Pending-GRN rows (`gate_<uuid>`) → the gate entry detail screen, since
    //   there's no reconciliation record yet but the gate entry exists.
    // Orphan GRN rows (`orphan_<uuid>`) → an info sheet, since there's no
    //   gate entry to navigate to.
    if (!item.isSyntheticRow) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => RecoExceptionDetailPage(record: item),
        ),
      );
      return;
    }

    if (item.isPendingGrn && item.gateEntryId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GateEntryDetailPage(entryId: item.gateEntryId!),
        ),
      );
      return;
    }

    if (item.isPendingGateEntry) {
      _showOrphanGrnSheet(context, item);
      return;
    }
  }

  void _showOrphanGrnSheet(
      BuildContext context, WarehouseReconciliationRecord item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        TableRow row(String label, String value) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(sheetContext)
                          .colorScheme
                          .onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    value.isEmpty ? '—' : value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            );

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.upload_file,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pending Gate Entry',
                      style: Theme.of(sheetContext)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'A SAP GRN was imported but no matching gate entry exists yet.',
                  style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                        color: Theme.of(sheetContext)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  children: [
                    row('GRN Number', item.grnNumber),
                    row('Challan', item.challanNo),
                    row('PO Number', item.poNumber),
                    row('Material', item.materialCode),
                    row('Vendor', item.vendorName),
                    row('Vendor Code', item.vendorCode),
                    row('GRN Qty', item.grnQty.toString()),
                    row(
                      'Posting Date',
                      item.grnPostingDate != null
                          ? _kShortDateFormat
                              .format(item.grnPostingDate!.toLocal())
                          : '—',
                    ),
                    row(
                      'Imported',
                      item.importedAt != null
                          ? _kListDateFormat.format(item.importedAt!.toLocal())
                          : '—',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
