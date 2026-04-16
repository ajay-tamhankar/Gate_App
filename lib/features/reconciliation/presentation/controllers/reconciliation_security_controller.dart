import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/pagination_model.dart';
import '../../data/reco_repository_impl.dart';
import '../../domain/entities/reconciliation_item.dart';

class ReconciliationFilterState {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const ReconciliationFilterState({this.dateFrom, this.dateTo});
}

class ReconciliationSecurityState {
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final List<ReconciliationItem> items;
  final PaginationModel? pagination;

  const ReconciliationSecurityState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.items = const [],
    this.pagination,
  });

  ReconciliationSecurityState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    List<ReconciliationItem>? items,
    PaginationModel? pagination,
  }) {
    return ReconciliationSecurityState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
    );
  }
}

final reconciliationFilterProvider =
    StateProvider<ReconciliationFilterState>((ref) {
  return const ReconciliationFilterState();
});

class ReconciliationSecurityController
    extends StateNotifier<ReconciliationSecurityState> {
  ReconciliationSecurityController(this.ref)
      : super(const ReconciliationSecurityState());

  final Ref ref;
  static const int _defaultLimit = 20;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final filter = ref.read(reconciliationFilterProvider);
      final repository = ref.read(recoRepositoryProvider);
      final response = await repository.getReconciliations(
        dateFrom: filter.dateFrom,
        dateTo: filter.dateTo,
        page: 1,
        limit: _defaultLimit,
      );
      state = state.copyWith(
        isLoading: false,
        items: response.items,
        pagination: response.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
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
      final filter = ref.read(reconciliationFilterProvider);
      final repository = ref.read(recoRepositoryProvider);
      final response = await repository.getReconciliations(
        dateFrom: filter.dateFrom,
        dateTo: filter.dateTo,
        page: pagination.page + 1,
        limit: pagination.limit,
      );

      state = state.copyWith(
        isLoadingMore: false,
        items: [...state.items, ...response.items],
        pagination: response.pagination,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}

final reconciliationSecurityControllerProvider = StateNotifierProvider<
    ReconciliationSecurityController, ReconciliationSecurityState>(
  (ref) => ReconciliationSecurityController(ref),
);
