import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gate_entry_repository.dart';
import '../models/gate_entry.dart';
import '../../data/gate_entry_repository_impl.dart';

final getGateEntryUseCaseProvider = Provider<GetGateEntryUseCase>((ref) {
  return GetGateEntryUseCase(ref.read(gateEntryRepositoryProvider));
});

class GetGateEntryUseCase {
  final GateEntryRepository _repository;

  GetGateEntryUseCase(this._repository);

  Future<GateEntry?> execute(String id) async {
    final response = await _repository.getGateEntry(id);
    if (response.success && response.data != null) {
      return response.data!;
    }
    return null;
  }
}
