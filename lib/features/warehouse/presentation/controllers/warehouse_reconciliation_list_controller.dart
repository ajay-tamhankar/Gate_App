import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/pagination_model.dart';
import '../../domain/models/warehouse_reconciliation.dart';

class WarehouseReconciliationListState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<WarehouseReconciliationRecord> items;
  final PaginationModel? pagination;

  const WarehouseReconciliationListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.items = const [],
    this.pagination,
  });

  WarehouseReconciliationListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    List<WarehouseReconciliationRecord>? items,
    PaginationModel? pagination,
  }) {
    return WarehouseReconciliationListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
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
  static const int _defaultLimit = 20;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.getRaw(
        '/reconciliations',
        queryParameters: const {'page': 1, 'limit': _defaultLimit},
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

      final pagination = PaginationModel.fromJson(
        response['pagination'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      );

      state = state.copyWith(
        isLoading: false,
        items: items,
        pagination: pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    final pagination = state.pagination;
    if (pagination == null ||
        !pagination.hasNext ||
        state.isLoading ||
        state.isLoadingMore) {
      return;
    }

    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.getRaw(
        '/reconciliations',
        queryParameters: {'page': pagination.page + 1, 'limit': pagination.limit},
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
      final moreItems = list
          .whereType<Map<String, dynamic>>()
          .map(WarehouseReconciliationRecord.fromJson)
          .where((item) => item.isActive)
          .toList();

      final newPagination = PaginationModel.fromJson(
        response['pagination'] as Map<String, dynamic>? ??
            const <String, dynamic>{},
      );

      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...moreItems],
        pagination: newPagination,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
}

final warehouseReconciliationListControllerProvider = StateNotifierProvider<
    WarehouseReconciliationListController, WarehouseReconciliationListState>(
  (ref) => WarehouseReconciliationListController(ref),
);
