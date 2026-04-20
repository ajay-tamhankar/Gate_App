import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reco_repository_impl.dart';
import '../../domain/entities/reconciliation_item.dart';
import '../../domain/reconciliation_period_filter.dart';

class ReconciliationFilterState {
  final ReconciliationPeriodFilter period;
  final bool hasExplicitSelection;

  const ReconciliationFilterState({
    this.period = ReconciliationPeriodFilter.all,
    this.hasExplicitSelection = false,
  });
}

class ReconciliationSecurityState {
  final bool isLoading;
  final String? error;
  final List<ReconciliationItem> items;

  const ReconciliationSecurityState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  ReconciliationSecurityState copyWith({
    bool? isLoading,
    String? error,
    List<ReconciliationItem>? items,
  }) {
    return ReconciliationSecurityState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
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

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final filter = ref.read(reconciliationFilterProvider);
      final repository = ref.read(recoRepositoryProvider);
      final items = await repository.getReconciliations(
        filter: filter.period,
      );
      state = state.copyWith(
        isLoading: false,
        items: items,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final reconciliationSecurityControllerProvider = StateNotifierProvider<
    ReconciliationSecurityController, ReconciliationSecurityState>(
  (ref) => ReconciliationSecurityController(ref),
);
