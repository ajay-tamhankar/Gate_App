import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gate_entry_repository.dart';
import '../../data/gate_entry_repository_impl.dart';
import '../../../../core/network/api_response.dart';

final getGateEntryAttachmentUrlUseCaseProvider =
    Provider<GetGateEntryAttachmentUrlUseCase>((ref) {
  return GetGateEntryAttachmentUrlUseCase(
      ref.read(gateEntryRepositoryProvider));
});

class GetGateEntryAttachmentUrlUseCase {
  final GateEntryRepository _repository;

  GetGateEntryAttachmentUrlUseCase(this._repository);

  Future<ApiResponse<String>> execute(String entryId, String attachmentId) {
    return _repository.getAttachmentUrl(entryId, attachmentId);
  }
}
