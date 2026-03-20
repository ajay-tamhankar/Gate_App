import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_provider.dart';

final sapGrnRepositoryProvider = Provider<SapGrnRepository>((ref) {
  return SapGrnRepository(apiClient: ref.read(apiClientProvider));
});

class SapGrnRepository {
  final ApiClient _apiClient;

  SapGrnRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<void>> importGrns({
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
          message: 'No file provided',
          error: ApiError(message: 'Missing file data'),
        );
      }

      final formData = FormData.fromMap({'file': filePart});
      final response = await _apiClient.postRaw(
        '/sap/grns/import',
        data: formData,
      );

      final success = response['success'] as bool? ?? false;
      final message = response['message'] as String? ?? '';
      if (!success) {
        final error = response['error'] is Map<String, dynamic>
            ? ApiError.fromJson(response['error'] as Map<String, dynamic>)
            : null;
        return ApiResponse<void>(
          success: false,
          message: message,
          error: error,
        );
      }

      return ApiResponse<void>(success: true, message: message);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to import SAP GRNs',
        error: ApiError(message: e.toString()),
      );
    }
  }
}
