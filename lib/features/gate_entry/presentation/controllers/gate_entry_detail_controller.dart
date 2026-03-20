import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/gate_entry.dart';
import '../../domain/models/attachment.dart';
import '../../domain/usecases/get_gate_entry_usecase.dart';
import '../../domain/usecases/get_gate_entry_attachments_usecase.dart';
import '../../domain/usecases/upload_gate_entry_attachment_usecase.dart';
import '../../domain/usecases/get_gate_entry_attachment_url_usecase.dart';
import 'attachment_cache_controller.dart';

class GateEntryDetailState {
  final bool isLoading;
  final bool isUploading;
  final String? error;
  final String? uploadError;
  final GateEntry? entry;
  final List<AttachmentInfo> attachments;

  GateEntryDetailState({
    this.isLoading = false,
    this.isUploading = false,
    this.error,
    this.uploadError,
    this.entry,
    this.attachments = const [],
  });

  GateEntryDetailState copyWith({
    bool? isLoading,
    bool? isUploading,
    String? error,
    String? uploadError,
    GateEntry? entry,
    List<AttachmentInfo>? attachments,
  }) {
    return GateEntryDetailState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      uploadError: uploadError,
      entry: entry ?? this.entry,
      attachments: attachments ?? this.attachments,
    );
  }
}

final gateEntryDetailControllerProvider = StateNotifierProvider.family<
    GateEntryDetailController, GateEntryDetailState, String>((ref, id) {
  return GateEntryDetailController(
    ref: ref,
    id: id,
    getGateEntryUseCase: ref.read(getGateEntryUseCaseProvider),
    getAttachmentsUseCase: ref.read(getGateEntryAttachmentsUseCaseProvider),
    uploadUseCase: ref.read(uploadGateEntryAttachmentUseCaseProvider),
    getUrlUseCase: ref.read(getGateEntryAttachmentUrlUseCaseProvider),
  )..fetch();
});

class GateEntryDetailController extends StateNotifier<GateEntryDetailState> {
  final Ref _ref;
  final String id;
  final GetGateEntryUseCase _getGateEntryUseCase;
  final GetGateEntryAttachmentsUseCase _getAttachmentsUseCase;
  final UploadGateEntryAttachmentUseCase _uploadUseCase;
  final GetGateEntryAttachmentUrlUseCase _getUrlUseCase;

  GateEntryDetailController({
    required Ref ref,
    required this.id,
    required GetGateEntryUseCase getGateEntryUseCase,
    required GetGateEntryAttachmentsUseCase getAttachmentsUseCase,
    required UploadGateEntryAttachmentUseCase uploadUseCase,
    required GetGateEntryAttachmentUrlUseCase getUrlUseCase,
  })  : _ref = ref,
        _getGateEntryUseCase = getGateEntryUseCase,
        _getAttachmentsUseCase = getAttachmentsUseCase,
        _uploadUseCase = uploadUseCase,
        _getUrlUseCase = getUrlUseCase,
        super(GateEntryDetailState());

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, error: null);
    final entry = await _getGateEntryUseCase.execute(id);
    if (entry == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load gate entry',
      );
      return;
    }
    final attachmentsResponse = await _getAttachmentsUseCase.execute(id);
    final apiAttachments = attachmentsResponse.success &&
            attachmentsResponse.data != null
        ? attachmentsResponse.data!
        : const <AttachmentInfo>[];
    final attachmentError = attachmentsResponse.success
        ? null
        : (attachmentsResponse.message.isNotEmpty
            ? attachmentsResponse.message
            : 'Failed to load attachments');


    final cached =
        _ref.read(attachmentCacheProvider.notifier).getAttachments(id);
    state = state.copyWith(
      isLoading: false,
      entry: entry,
      attachments: _mergeAttachments(apiAttachments, cached),
      uploadError: attachmentError,
    );
  }

  Future<bool> uploadAttachment({
    required String fileName,
    String? filePath,
    List<int>? bytes,
  }) async {
    state = state.copyWith(isUploading: true, uploadError: null);
    final response = await _uploadUseCase.execute(
      id,
      fileName: fileName,
      filePath: filePath,
      bytes: bytes,
    );

    if (!response.success || response.data == null) {
      state = state.copyWith(
        isUploading: false,
        uploadError: response.message.isNotEmpty
            ? response.message
            : 'Attachment upload failed',
      );
      return false;
    }

    state = state.copyWith(
      isUploading: false,
      attachments: _mergeAttachments(
        [response.data!],
        state.attachments,
      ),
    );
    _ref
        .read(attachmentCacheProvider.notifier)
        .addAttachment(id, response.data!);
    return true;
  }

  Future<String?> fetchAttachmentUrl(String attachmentId) async {
    final response = await _getUrlUseCase.execute(id, attachmentId);
    if (response.success && response.data != null) {
      return response.data!;
    }
    state = state.copyWith(
      uploadError:
          response.message.isNotEmpty ? response.message : 'Failed to load URL',
    );
    return null;
  }

  List<AttachmentInfo> _mergeAttachments(
      List<AttachmentInfo> primary, List<AttachmentInfo> secondary) {
    final map = <String, AttachmentInfo>{};
    for (final a in secondary) {
      map[a.id] = a;
    }
    for (final a in primary) {
      map[a.id] = a;
    }
    return map.values.toList();
  }
}
