import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../domain/models/grn_import_models.dart';
import '../../../core/network/dio_provider.dart';

final sapGrnRepositoryProvider = Provider<SapGrnRepository>((ref) {
  return SapGrnRepository(apiClient: ref.read(apiClientProvider));
});

class SapGrnRepository {
  final ApiClient _apiClient;
  static final DateFormat _apiDateFormat = DateFormat('dd-MM-yy');

  SapGrnRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<GrnImportResult?>> importGrns({
    required String fileName,
    String? filePath,
    List<int>? bytes,
    bool runReconciliation = false,
    DateTime? reconciliationDate,
    DateTime? reconciliationRangeStart,
    DateTime? reconciliationRangeEnd,
    Map<String, dynamic>? reconciliationOptions,
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

      final Map<String, dynamic> fields = {
        'file': filePart,
        'runReconciliation': runReconciliation.toString(),
      };

      if (runReconciliation) {
        if (reconciliationDate != null) {
          fields['date'] = _formatApiDate(reconciliationDate);
        } else if (reconciliationRangeStart != null &&
            reconciliationRangeEnd != null) {
          fields['dateRange'] =
              '${_formatApiDate(reconciliationRangeStart)} to ${_formatApiDate(reconciliationRangeEnd)}';
        }
      }

      if (reconciliationOptions != null) {
        fields['reconciliation'] = jsonEncode(reconciliationOptions);
      }

      final formData = FormData.fromMap(fields);
      final response = await _apiClient.postRaw(
        '/sap/grns/import',
        data: formData,
      );

      final success = response['success'] as bool? ?? false;
      final message = response['message'] as String? ?? '';
      final data = response['data'];

      if (!success) {
        final error = response['error'] is Map<String, dynamic>
            ? ApiError.fromJson(response['error'] as Map<String, dynamic>)
            : null;
        return ApiResponse<GrnImportResult?>(
          success: false,
          message: message,
          error: error,
        );
      }

      GrnImportResult? result;
      if (data != null && data is Map<String, dynamic>) {
        result = GrnImportResult.fromJson(data);
      }

      return ApiResponse<GrnImportResult?>(
        success: true,
        message: message,
        data: result,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to import SAP GRNs',
        error: ApiError(message: e.toString()),
      );
    }
  }

  String _formatApiDate(DateTime value) {
    return _apiDateFormat.format(value);
  }
}
