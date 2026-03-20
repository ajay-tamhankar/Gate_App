import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/pagination_model.dart';
import '../gate_entry_repository.dart';
import '../models/gate_entry.dart';
import '../../data/gate_entry_repository_impl.dart';

final getGateEntriesUseCaseProvider = Provider<GetGateEntriesUseCase>((ref) {
  return GetGateEntriesUseCase(ref.read(gateEntryRepositoryProvider));
});

class GetGateEntriesUseCase {
  final GateEntryRepository _repository;

  GetGateEntriesUseCase(this._repository);

  Future<ApiResponse<PaginatedResponse<GateEntry>>> execute(
      {int page = 1, int limit = 20}) {
    return _repository.getGateEntries(page: page, limit: limit);
  }
}
