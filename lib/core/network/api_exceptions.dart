class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = 'Unauthorized', dynamic data])
      : super(statusCode: 401, data: data);
}

class NetworkException extends ApiException {
  NetworkException([super.message = 'No Internet Connection']);
}

class ServerException extends ApiException {
  ServerException(
      [super.message = 'Server validation failed',
      dynamic data,
      int? statusCode])
      : super(statusCode: statusCode, data: data);
}
