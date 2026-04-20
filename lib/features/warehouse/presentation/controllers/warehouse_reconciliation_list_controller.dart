import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/models/warehouse_reconciliation.dart';
import '../../../reconciliation/domain/reconciliation_period_filter.dart';

class WarehouseReconciliationListState {
  final bool isLoading;
  final String? error;
  final List<WarehouseReconciliationRecord> items;
  final ReconciliationPeriodFilter activeFilter;

  const WarehouseReconciliationListState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.activeFilter = ReconciliationPeriodFilter.all,
  });

  WarehouseReconciliationListState copyWith({
    bool? isLoading,
    String? error,
    List<WarehouseReconciliationRecord>? items,
    ReconciliationPeriodFilter? activeFilter,
  }) {
    return WarehouseReconciliationListState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
      activeFilter: activeFilter ?? this.activeFilter,
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

  Future<void> refresh({ReconciliationPeriodFilter? filter}) async {
    final effectiveFilter = filter ?? state.activeFilter;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final apiClient = ref.read(apiClientProvider);
      final query = <String, dynamic>{};
      if (effectiveFilter != ReconciliationPeriodFilter.all) {
        query['filter'] = effectiveFilter.apiValue;
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
