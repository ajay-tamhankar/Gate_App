import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../gate_entry_repository.dart';
import '../models/attachment.dart';
import '../../data/gate_entry_repository_impl.dart';
import '../../../../core/network/api_response.dart';

final uploadGateEntryAttachmentUseCaseProvider =
    Provider<UploadGateEntryAttachmentUseCase>((ref) {
  return UploadGateEntryAttachmentUseCase(
      ref.read(gateEntryRepositoryProvider));
});

class UploadGateEntryAttachmentUseCase {
  final GateEntryRepository _repository;

  UploadGateEntryAttachmentUseCase(this._repository);

  Future<ApiResponse<AttachmentInfo>> execute(
    String entryId, {
    required String fileName,
    String? filePath,
    List<int>? bytes,
  }) {
    return _repository.uploadAttachment(
      entryId,
      fileName: fileName,
      filePath: filePath,
      bytes: bytes,
    );
  }
}
