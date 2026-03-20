import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../gate_entry_repository.dart';
import '../../data/gate_entry_repository_impl.dart';

final verifyGateEntryUseCaseProvider = Provider<VerifyGateEntryUseCase>((ref) {
  return VerifyGateEntryUseCase(ref.read(gateEntryRepositoryProvider));
});

class VerifyGateEntryUseCase {
  final GateEntryRepository _repository;

  VerifyGateEntryUseCase(this._repository);

  Future<ApiResponse<void>> execute(String id) {
    return _repository.verifyGateEntry(id);
  }
}

final approveGateEntryUseCaseProvider =
    Provider<ApproveGateEntryUseCase>((ref) {
  return ApproveGateEntryUseCase(ref.read(gateEntryRepositoryProvider));
});

class ApproveGateEntryUseCase {
  final GateEntryRepository _repository;

  ApproveGateEntryUseCase(this._repository);

  Future<ApiResponse<void>> execute(String id) {
    return _repository.approveGateEntry(id);
  }
}

final closeGateEntryUseCaseProvider = Provider<CloseGateEntryUseCase>((ref) {
  return CloseGateEntryUseCase(ref.read(gateEntryRepositoryProvider));
});

class CloseGateEntryUseCase {
  final GateEntryRepository _repository;

  CloseGateEntryUseCase(this._repository);

  Future<ApiResponse<void>> execute(String id) {
    return _repository.closeGateEntry(id);
  }
}
