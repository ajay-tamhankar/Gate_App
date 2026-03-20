import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../../core/network/pagination_model.dart';
import '../domain/gate_entry_repository.dart';
import '../domain/models/attachment.dart';
import '../domain/models/gate_entry.dart';
import '../domain/models/gate_entry_item.dart';
import 'dto/create_gate_entry_request.dart';
import 'dto/gate_entry_response.dart';

final gateEntryRepositoryProvider = Provider<GateEntryRepository>((ref) {
  return GateEntryRepositoryImpl(apiClient: ref.read(apiClientProvider));
});

class GateEntryRepositoryImpl implements GateEntryRepository {
  final ApiClient _apiClient;

  GateEntryRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  GateEntry _mapDtoToDomain(GateEntryResponse dto) {
    return GateEntry(
      id: dto.id,
      gateEntryNo: dto.gateEntryNo,
      gateTimestamp: dto.gateTimestamp != null
          ? DateTime.tryParse(dto.gateTimestamp!)
          : null,
      gateMovement: dto.gateMovement.toLowerCase().contains('in')
          ? GateMovement.inMovement
          : GateMovement.outMovement,
      challanNo: dto.challanNo,
      transporterName: dto.transporterName,
      vehicleNo: dto.vehicleNo,
      vendorName: dto.vendorName,
      status: dto.status ?? 'unknown',
      items: dto.items
          .map((item) => GateEntryItem(
                id: item.id,
                poNumber: item.poNumber,
                materialCode: item.materialCode,
                challanQty: item.challanQty,
                uom: item.uom,
              ))
          .toList(),
    );
  }

  @override
  Future<ApiResponse<PaginatedResponse<GateEntry>>> getGateEntries(
      {int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.getRaw(
        '/gate-entries',
        queryParameters: {'page': page, 'limit': limit},
      );

      final success = response['success'] as bool? ?? false;
      final message = response['message'] as String? ?? '';

      if (success) {
        final List<dynamic> rawItems =
            (response['data'] as List<dynamic>? ?? []);
        final items = rawItems
            .map((json) => _mapDtoToDomain(GateEntryResponse.fromJson(json)))
            .toList();

        final paginationJson =
            response['pagination'] as Map<String, dynamic>? ?? {};
        final pagination = PaginationModel.fromJson(paginationJson);

        return ApiResponse<PaginatedResponse<GateEntry>>(
          success: true,
          message: message,
          data: PaginatedResponse(items: items, pagination: pagination),
        );
      }

      final error = response['error'] is Map<String, dynamic>
          ? ApiError.fromJson(response['error'] as Map<String, dynamic>)
          : null;
      return ApiResponse<PaginatedResponse<GateEntry>>(
        success: false,
        message: message,
        error: error,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to fetch gate entries',
        error: ApiError(message: e.toString()),
      );
    }
  }

  @override
  Future<ApiResponse<GateEntry>> getGateEntry(String id) async {
    final response = await _apiClient.get<GateEntryResponse>(
      '/gate-entries/$id',
      fromJsonT: (json) => GateEntryResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      return ApiResponse<GateEntry>(
        success: true,
        message: response.message,
        data: _mapDtoToDomain(response.data!),
      );
    }

    return ApiResponse<GateEntry>(
      success: false,
      message: response.message,
      error: response.error,
    );
  }

  @override
  Future<ApiResponse<GateEntry>> createGateEntry(
      CreateGateEntryRequest request) async {
    final response = await _apiClient.post<GateEntryResponse>(
      '/gate-entries',
      data: request.toJson(),
      fromJsonT: (json) => GateEntryResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      return ApiResponse<GateEntry>(
        success: true,
        message: response.message,
        data: _mapDtoToDomain(response.data!),
      );
    }

    return ApiResponse<GateEntry>(
      success: false,
      message: response.message,
      error: response.error,
    );
  }

  @override
  Future<ApiResponse<GateEntry>> updateGateEntry(
      String id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch<GateEntryResponse>(
      '/gate-entries/$id',
      data: data,
      fromJsonT: (json) => GateEntryResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      return ApiResponse<GateEntry>(
        success: true,
        message: response.message,
        data: _mapDtoToDomain(response.data!),
      );
    }

    return ApiResponse<GateEntry>(
      success: false,
      message: response.message,
      error: response.error,
    );
  }

  @override
  Future<ApiResponse<void>> verifyGateEntry(String id) async {
    return _apiClient.post<void>('/gate-entries/$id/verify');
  }

  @override
  Future<ApiResponse<void>> approveGateEntry(String id) async {
    return _apiClient.post<void>('/gate-entries/$id/approve');
  }

  @override
  Future<ApiResponse<void>> closeGateEntry(String id) async {
    return _apiClient.post<void>('/gate-entries/$id/close');
  }

  @override
  @override
  Future<ApiResponse<List<AttachmentInfo>>> getAttachments(String id) async {
    try {
      final response = await _apiClient.getRaw('/gate-entries/$id');

      final success = response['success'] as bool? ?? false;
      final message = response['message'] as String? ?? '';
      if (!success) {
        final error = response['error'] is Map<String, dynamic>
            ? ApiError.fromJson(response['error'] as Map<String, dynamic>)
            : null;
        return ApiResponse<List<AttachmentInfo>>(
          success: false,
          message: message,
          error: error,
        );
      }

      final data = response['data'];
      final detail =
          data is Map<String, dynamic> ? data : const <String, dynamic>{};
      final list = detail['attachments'] as List? ?? const [];
      final attachments = list
          .map((e) {
            final map = e as Map<String, dynamic>;
            final idValue = (map['id'] ??
                    map['attachmentId'] ??
                    map['attachment_id'] ??
                    '')
                .toString();
            if (idValue.isEmpty) return null;
            final nameValue = (map['fileName'] ??
                    map['filename'] ??
                    map['name'] ??
                    idValue)
                .toString();
            return AttachmentInfo(id: idValue, fileName: nameValue);
          })
          .whereType<AttachmentInfo>()
          .toList();

      return ApiResponse<List<AttachmentInfo>>(
        success: true,
        message: message,
        data: attachments,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to load attachments',
        error: ApiError(message: e.toString()),
      );
    }
  }

  @override
  Future<ApiResponse<AttachmentInfo>> uploadAttachment(
    String id, {
    required String fileName,
    String? filePath,
    List<int>? bytes,
  }) async {
    try {
      MultipartFile filePart;
      if (filePath != null && filePath.isNotEmpty) {
        filePart = await MultipartFile.fromFile(filePath, filename: fileName);
      } else if (bytes != null) {
        filePart = MultipartFile.fromBytes(bytes, filename: fileName);
      } else {
        return ApiResponse(
          success: false,
          message: 'No attachment data provided',
          error: ApiError(message: 'Missing file data'),
        );
      }

      final formData = FormData.fromMap({'file': filePart});
      final response = await _apiClient.postRaw(
        '/gate-entries/$id/attachments',
        data: formData,
      );

      final success = response['success'] as bool? ?? false;
      final message = response['message'] as String? ?? '';
      if (!success) {
        final error = response['error'] is Map<String, dynamic>
            ? ApiError.fromJson(response['error'] as Map<String, dynamic>)
            : null;
        return ApiResponse<AttachmentInfo>(
          success: false,
          message: message,
          error: error,
        );
      }

      final data = response['data'];
      String idValue = '';
      String nameValue = fileName;
      if (data is Map<String, dynamic>) {
        idValue = (data['id'] ??
                data['attachmentId'] ??
                data['attachment_id'] ??
                '')
            .toString();
        nameValue = (data['fileName'] ??
                data['filename'] ??
                data['name'] ??
                fileName)
            .toString();
      }

      if (idValue.isEmpty) {
        return ApiResponse(
          success: false,
          message: 'Attachment upload failed',
          error: ApiError(message: 'Missing attachment id in response'),
        );
      }

      return ApiResponse<AttachmentInfo>(
        success: true,
        message: message,
        data: AttachmentInfo(id: idValue, fileName: nameValue),
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to upload attachment',
        error: ApiError(message: e.toString()),
      );
    }
  }

  @override
  Future<ApiResponse<String>> getAttachmentUrl(
      String id, String attachmentId) async {
    try {
      final response = await _apiClient.getRaw(
        '/gate-entries/$id/attachments/$attachmentId/url',
      );

      final success = response['success'] as bool? ?? false;
      final message = response['message'] as String? ?? '';
      if (!success) {
        final error = response['error'] is Map<String, dynamic>
            ? ApiError.fromJson(response['error'] as Map<String, dynamic>)
            : null;
        return ApiResponse<String>(
          success: false,
          message: message,
          error: error,
        );
      }

      String url = '';
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        url = (data['url'] ?? data['signedUrl'] ?? '').toString();
      } else if (data is String) {
        url = data;
      } else if (response['url'] != null) {
        url = response['url'].toString();
      }

      if (url.isEmpty) {
        return ApiResponse(
          success: false,
          message: 'Attachment URL not found',
          error: ApiError(message: 'Missing attachment URL in response'),
        );
      }

      return ApiResponse<String>(success: true, message: message, data: url);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to fetch attachment URL',
        error: ApiError(message: e.toString()),
      );
    }
  }
}
