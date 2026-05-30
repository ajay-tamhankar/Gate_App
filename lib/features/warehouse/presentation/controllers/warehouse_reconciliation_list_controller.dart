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

  const WarehouseReconciliationListState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.activeFilter = ReconciliationPeriodFilter.all,
    this.search = '',
  });

  WarehouseReconciliationListState copyWith({
    bool? isLoading,
    Object? error = _kUnset,
    List<WarehouseReconciliationRecord>? items,
    ReconciliationPeriodFilter? activeFilter,
    String? search,
  }) {
    return WarehouseReconciliationListState(
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _kUnset) ? this.error : error as String?,
      items: items ?? this.items,
      activeFilter: activeFilter ?? this.activeFilter,
      search: search ?? this.search,
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
  }) async {
    final effectiveFilter = filter ?? state.activeFilter;
    final effectiveSearch =
        identical(search, _kUnset) ? state.search : (search as String? ?? '');
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
      final response = await apiClient.getRaw(
        '/reconciliations',
        queryParameters: query.isEmpty ? null : query,
      );

      final success = response['success'] as bool? ?? false;
      if (!success) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to load reconciliations',
        );
      }

      final data = response['data'];
      final list = data is List ? data : const [];
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(WarehouseReconciliationRecord.fromJson)
          .where((item) => item.isActive)
          .toList();

      state = state.copyWith(
        isLoading: false,
        items: items,
        activeFilter: effectiveFilter,
        search: effectiveSearch,
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
