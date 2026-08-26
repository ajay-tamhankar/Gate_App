import '../../../core/network/api_response.dart';
import '../data/dto/create_gate_entry_request.dart';
import '../data/dto/check_challan_uniqueness_response.dart';
import 'models/attachment.dart';
import 'models/gate_entry.dart';
import 'models/gate_entry_list_response.dart';
import 'models/gate_entry_query.dart';
import 'models/vendor.dart';

abstract class GateEntryRepository {
  Future<ApiResponse<GateEntryListResponse>> getGateEntries({
    GateEntryQuery? query,
  });
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
  Future<ApiResponse<List<Vendor>>> searchVendors(String query);
  Future<ApiResponse<CheckChallanUniquenessResponse>> checkChallanUniqueness(
    String challanNo, {
    String? vendorCode,
    String? financialYear,
  });
  Future<ApiResponse<GateEntry>> gateOut(String id, {String? remarks});
}
