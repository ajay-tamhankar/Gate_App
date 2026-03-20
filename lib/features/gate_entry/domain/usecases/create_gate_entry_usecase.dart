import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../gate_entry_repository.dart';
import '../models/gate_entry.dart';
import '../../data/dto/create_gate_entry_request.dart';
import '../../data/gate_entry_repository_impl.dart';

final createGateEntryUseCaseProvider = Provider<CreateGateEntryUseCase>((ref) {
  return CreateGateEntryUseCase(ref.read(gateEntryRepositoryProvider));
});

class CreateGateEntryUseCase {
  final GateEntryRepository _repository;

  CreateGateEntryUseCase(this._repository);

  Future<ApiResponse<GateEntry>> execute(CreateGateEntryRequest request) {
    return _repository.createGateEntry(request);
  }
}
