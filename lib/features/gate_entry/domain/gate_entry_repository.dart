import '../../../../core/network/api_response.dart';
import '../../../../core/network/pagination_model.dart';
import '../data/dto/create_gate_entry_request.dart';
import 'models/attachment.dart';
import 'models/gate_entry.dart';

abstract class GateEntryRepository {
  Future<ApiResponse<PaginatedResponse<GateEntry>>> getGateEntries(
      {int page = 1, int limit = 20});
  Future<ApiResponse<GateEntry>> getGateEntry(String id);
  Future<ApiResponse<GateEntry>> createGateEntry(
      CreateGateEntryRequest request);
  Future<ApiResponse<GateEntry>> updateGateEntry(
      String id, Map<String, dynamic> data);
  Future<ApiResponse<void>> verifyGateEntry(String id);
  Future<ApiResponse<void>> approveGateEntry(String id);
  Future<ApiResponse<void>> closeGateEntry(String id);
  Future<ApiResponse<List<AttachmentInfo>>> getAttachments(String id);
  Future<ApiResponse<AttachmentInfo>> uploadAttachment(
    String id, {
    required String fileName,
    String? filePath,
    List<int>? bytes,
  });
  Future<ApiResponse<String>> getAttachmentUrl(String id, String attachmentId);
}
