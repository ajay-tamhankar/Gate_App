import 'package:dio/dio.dart';
import 'api_response.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<Map<String, dynamic>> getRaw(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> postRaw(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> putRaw(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJsonT,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<Map<String, dynamic>> patchRaw(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> deleteRaw(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Unexpected response format');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Pulls the most useful, human-readable message out of a [DioException].
  /// Servers in this app return an envelope shaped like:
  /// `{ "success": false, "message": "...", "error": { "message": "..." } }`
  /// even on non-2xx responses. Prefer that over Dio's stringified type.
  String _extractErrorMessage(DioException e) {
    final body = e.response?.data;
    if (body is Map<String, dynamic>) {
      final err = body['error'];
      if (err is Map && err['message'] != null) {
        final m = err['message'].toString().trim();
        if (m.isNotEmpty) return m;
      }
      final msg = body['message'];
      if (msg != null) {
        final m = msg.toString().trim();
        if (m.isNotEmpty) return m;
      }
    }
    if (body is String && body.trim().isNotEmpty) return body.trim();
    return e.message ?? 'Network error occurred';
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        cancelToken: cancelToken,
      );
      return ApiResponse.fromJson(response.data, fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null &&
          error.response?.data is Map<String, dynamic>) {
        try {
          return ApiResponse.fromJson(
              error.response!.data as Map<String, dynamic>, null);
        } catch (_) {}
      }
      return ApiResponse<T>(
        success: false,
        message: error.message ?? 'Network error occurred',
        error: ApiError(
            message: error.message ?? 'Unknown error',
            details: error.type.toString()),
      );
    }
    return ApiResponse<T>(
      success: false,
      message: 'An unexpected error occurred',
      error: ApiError(message: error.toString()),
    );
  }
}
