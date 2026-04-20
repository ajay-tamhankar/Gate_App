import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../gate_entry_repository.dart';
import '../models/gate_entry_list_response.dart';
import '../models/gate_entry_query.dart';
import '../../data/gate_entry_repository_impl.dart';

final getGateEntriesUseCaseProvider = Provider<GetGateEntriesUseCase>((ref) {
  return GetGateEntriesUseCase(ref.read(gateEntryRepositoryProvider));
});

class GetGateEntriesUseCase {
  final GateEntryRepository _repository;

  GetGateEntriesUseCase(this._repository);

  Future<ApiResponse<GateEntryListResponse>> execute({
    GateEntryQuery? query,
  }) {
    return _repository.getGateEntries(query: query);
  }
}
