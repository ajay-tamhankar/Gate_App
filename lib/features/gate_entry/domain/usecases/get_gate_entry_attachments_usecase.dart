import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gate_entry_repository.dart';
import '../../data/gate_entry_repository_impl.dart';
import '../../../../core/network/api_response.dart';
import '../models/attachment.dart';

final getGateEntryAttachmentsUseCaseProvider =
    Provider<GetGateEntryAttachmentsUseCase>((ref) {
  return GetGateEntryAttachmentsUseCase(
      ref.read(gateEntryRepositoryProvider));
});

class GetGateEntryAttachmentsUseCase {
  final GateEntryRepository _repository;

  GetGateEntryAttachmentsUseCase(this._repository);

  Future<ApiResponse<List<AttachmentInfo>>> execute(String entryId) {
    return _repository.getAttachments(entryId);
  }
}
