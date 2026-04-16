import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../gate_entry_repository.dart';
import '../../data/gate_entry_repository_impl.dart';
import '../models/gate_entry.dart';

final gateOutUseCaseProvider = Provider<GateOutUseCase>((ref) {
  return GateOutUseCase(ref.read(gateEntryRepositoryProvider));
});

class GateOutUseCase {
  final GateEntryRepository _repository;

  GateOutUseCase(this._repository);

  Future<ApiResponse<GateEntry>> execute(String id, {String? remarks}) {
    return _repository.gateOut(id, remarks: remarks);
  }
}
