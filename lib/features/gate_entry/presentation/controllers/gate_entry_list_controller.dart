import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/get_gate_entries.dart';
import '../../domain/entities/gate_entry.dart';

class GateEntryListController extends AsyncNotifier<List<GateEntry>> {
  @override
  Future<List<GateEntry>> build() async {
    return ref.watch(getGateEntriesProvider.future);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(gateEntryRepositoryProvider);
      return repository.getGateEntries();
    });
  }
}

final gateEntryListControllerProvider =
    AsyncNotifierProvider<GateEntryListController, List<GateEntry>>(
  GateEntryListController.new,
);
