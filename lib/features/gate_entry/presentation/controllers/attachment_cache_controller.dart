import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/attachment.dart';

class AttachmentCacheController
    extends StateNotifier<Map<String, List<AttachmentInfo>>> {
  AttachmentCacheController() : super(const {});

  void addAttachment(String entryId, AttachmentInfo attachment) {
    final existing = state[entryId] ?? const <AttachmentInfo>[];
    final updated = [
      attachment,
      ...existing.where((a) => a.id != attachment.id),
    ];
    state = {
      ...state,
      entryId: updated,
    };
  }

  List<AttachmentInfo> getAttachments(String entryId) {
    return state[entryId] ?? const <AttachmentInfo>[];
  }
}

final attachmentCacheProvider = StateNotifierProvider<AttachmentCacheController,
    Map<String, List<AttachmentInfo>>>(
  (ref) => AttachmentCacheController(),
);
