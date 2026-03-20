import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reco_repository_impl.dart';
import '../../domain/entities/reconciliation_item.dart';

class ReconciliationFilterState {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const ReconciliationFilterState({this.dateFrom, this.dateTo});
}

final reconciliationFilterProvider =
    StateProvider<ReconciliationFilterState>((ref) {
  return const ReconciliationFilterState();
});

class ReconciliationSecurityController
    extends AsyncNotifier<List<ReconciliationItem>> {
  @override
  Future<List<ReconciliationItem>> build() async {
    final filter = ref.watch(reconciliationFilterProvider);
    final repository = ref.read(recoRepositoryProvider);
    return repository.getReconciliations(
      dateFrom: filter.dateFrom,
      dateTo: filter.dateTo,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final filter = ref.read(reconciliationFilterProvider);
      final repository = ref.read(recoRepositoryProvider);
      return repository.getReconciliations(
        dateFrom: filter.dateFrom,
        dateTo: filter.dateTo,
      );
    });
  }
}

final reconciliationSecurityControllerProvider =
    AsyncNotifierProvider<ReconciliationSecurityController,
        List<ReconciliationItem>>(
  ReconciliationSecurityController.new,
);
