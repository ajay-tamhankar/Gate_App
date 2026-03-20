import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../gate_entry_repository.dart';
import '../models/gate_entry.dart';
import '../../data/gate_entry_repository_impl.dart';

final updateGateEntryUseCaseProvider = Provider<UpdateGateEntryUseCase>((ref) {
  return UpdateGateEntryUseCase(ref.read(gateEntryRepositoryProvider));
});

class UpdateGateEntryUseCase {
  final GateEntryRepository _repository;

  UpdateGateEntryUseCase(this._repository);

  Future<ApiResponse<GateEntry>> execute(String id, Map<String, dynamic> data) {
    return _repository.updateGateEntry(id, data);
  }
}
