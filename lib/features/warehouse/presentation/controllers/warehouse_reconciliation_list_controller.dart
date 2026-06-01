import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/models/warehouse_reconciliation.dart';
import '../../../reconciliation/domain/reconciliation_period_filter.dart';

const _kUnset = Object();

class WarehouseReconciliationListState {
  final bool isLoading;
  final String? error;
  final List<WarehouseReconciliationRecord> items;
  final ReconciliationPeriodFilter activeFilter;
  final String search;

  /// Server-side status filter (one of the seven status keys), or null
  /// when no per-status filter is active.
  final String? statusFilter;

  /// Count of "orphan" GRNs (uploaded GRNs with no matching gate entry).
  /// Mirrors `reconciliation.summary.orphanGrns.total` from the API.
  final int orphanGrnCount;

  /// Per-status counters from `reconciliation.summary.gateEntries.byStatus`.
  final WarehouseReconciliationStatusBreakdown statusBreakdown;

  const WarehouseReconciliationListState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.activeFilter = ReconciliationPeriodFilter.all,
    this.search = '',
    this.statusFilter,
    this.orphanGrnCount = 0,
    this.statusBreakdown =
        const WarehouseReconciliationStatusBreakdown(),
  });

  WarehouseReconciliationListState copyWith({
    bool? isLoading,
    Object? error = _kUnset,
    List<WarehouseReconciliationRecord>? items,
    ReconciliationPeriodFilter? activeFilter,
    String? search,
    Object? statusFilter = _kUnset,
    int? orphanGrnCount,
    WarehouseReconciliationStatusBreakdown? statusBreakdown,
  }) {
    return WarehouseReconciliationListState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _kUnset) ? this.error : error as String?,
      items: items ?? this.items,
      activeFilter: activeFilter ?? this.activeFilter,
      search: search ?? this.search,
      statusFilter: identical(statusFilter, _kUnset)
          ? this.statusFilter
          : statusFilter as String?,
      orphanGrnCount: orphanGrnCount ?? this.orphanGrnCount,
      statusBreakdown: statusBreakdown ?? this.statusBreakdown,
    );
  }
}

class WarehouseReconciliationListController
    extends StateNotifier<WarehouseReconciliationListState> {
  WarehouseReconciliationListController(this.ref)
      : super(const WarehouseReconciliationListState()) {
    refresh();
  }

  final Ref ref;

  Future<void> refresh({
    ReconciliationPeriodFilter? filter,
    Object? search = _kUnset,
    Object? statusFilter = _kUnset,
  }) async {
    final effectiveFilter = filter ?? state.activeFilter;
    final effectiveSearch =
        identical(search, _kUnset) ? state.search : (search as String? ?? '');
    final effectiveStatus = identical(statusFilter, _kUnset)
        ? state.statusFilter
        : statusFilter as String?;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final apiClient = ref.read(apiClientProvider);
      final query = <String, dynamic>{};
      if (effectiveFilter != ReconciliationPeriodFilter.all) {
        query['filter'] = effectiveFilter.apiValue;
      }
      final trimmed = effectiveSearch.trim();
      if (trimmed.isNotEmpty) {
        query['q'] = trimmed;
      }
      if (effectiveStatus != null && effectiveStatus.isNotEmpty) {
        query['status'] = effectiveStatus;
      }
      final response = await apiClient.getRaw(
        '/reconciliations',
        queryParameters: query.isEmpty ? null : query,
      );

      final success = response['success'] as bool? ?? false;
      if (!success) {
        throw Exception(
          response['message']?.toString() ?? 'Failed to load reconciliations',
        );
      }

      final data = response['data'];
      final list = data is List ? data : const [];
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(WarehouseReconciliationRecord.fromJson)
          .where((item) => item.isActive)
          .toList();

      // `reconciliation.summary.gateEntries.byStatus` + `orphanGrnCount`
      // (with a sub-object fallback so we accept either shape).
      final reco = response['reconciliation'] is Map<String, dynamic>
          ? response['reconciliation'] as Map<String, dynamic>
          : const <String, dynamic>{};
      final summary = reco['summary'] is Map<String, dynamic>
          ? reco['summary'] as Map<String, dynamic>
          : const <String, dynamic>{};
      final gateEntriesSummary = summary['gateEntries'] is Map<String, dynamic>
          ? summary['gateEntries'] as Map<String, dynamic>
          : const <String, dynamic>{};
      final byStatus = gateEntriesSummary['byStatus'] is Map<String, dynamic>
          ? gateEntriesSummary['byStatus'] as Map<String, dynamic>
          : const <String, dynamic>{};
      final breakdown = WarehouseReconciliationStatusBreakdown.fromJson(
        byStatus,
      );

      final topLevelOrphanCount = response['orphanGrnCount'];
      int orphanCount = 0;
      if (topLevelOrphanCount is num) {
        orphanCount = topLevelOrphanCount.toInt();
      } else if (summary['orphanGrns'] is Map<String, dynamic>) {
        final og = summary['orphanGrns'] as Map<String, dynamic>;
        final t = og['total'];
        if (t is num) orphanCount = t.toInt();
      }

      state = state.copyWith(
        isLoading: false,
        items: items,
        activeFilter: effectiveFilter,
        search: effectiveSearch,
        statusFilter: effectiveStatus,
        orphanGrnCount: orphanCount,
        statusBreakdown: breakdown,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final warehouseReconciliationListControllerProvider = StateNotifierProvider<
    WarehouseReconciliationListController, WarehouseReconciliationListState>(
  (ref) => WarehouseReconciliationListController(ref),
);
