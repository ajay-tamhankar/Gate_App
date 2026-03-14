import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_gate_entry_repository.dart';
import 'entities/gate_entry.dart';
import 'gate_entry_repository.dart';

final gateEntryRepositoryProvider = Provider<GateEntryRepository>((ref) {
  return MockGateEntryRepository(); // Swap with real implementation later
});

final getGateEntriesProvider = FutureProvider<List<GateEntry>>((ref) async {
  final repository = ref.watch(gateEntryRepositoryProvider);
  return repository.getGateEntries();
});
