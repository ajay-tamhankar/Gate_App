import 'package:dio/dio.dart';
import 'api_exceptions.dart';

class ErrorMapper {
  static ApiException mapError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return NetworkException('Connection timeout');
        case DioExceptionType.badResponse:
          final response = error.response;
          if (response?.statusCode == 401) {
            return UnauthorizedException('Unauthorized access', response?.data);
          }
          if (response?.statusCode != null && response!.statusCode! >= 500) {
            return ServerException(
                'Server error', response.data, response.statusCode);
          }
          return ApiException(
            response?.data['message'] ?? 'Unexpected error occurred',
            statusCode: response?.statusCode,
            data: response?.data,
          );
        case DioExceptionType.cancel:
          return ApiException('Request cancelled');
        case DioExceptionType.connectionError:
          return NetworkException('No Internet Connection');
        default:
          return ApiException('An unexpected network error occurred');
      }
    }
    return ApiException(error.toString());
  }
}
