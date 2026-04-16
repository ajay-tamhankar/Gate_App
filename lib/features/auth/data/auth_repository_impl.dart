import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/token_storage.dart';
import '../domain/auth_repository.dart';
import '../domain/models/auth_result.dart';
import '../domain/models/user.dart';
import 'dto/login_request.dart';
import 'dto/user_response.dart';
import '../../../core/network/dio_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dio: ref.read(dioProvider),
    apiClient: ref.read(apiClientProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required Dio dio,
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _dio = dio,
        _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  @override
  Future<ApiResponse<AuthResult>> login(LoginRequest request) async {
    try {
      final response = await _dio.post<dynamic>(
        '/auth/login',
        data: request.toJson(),
      );

      final body = response.data;
      if (body is! Map<String, dynamic>) {
        return ApiResponse<AuthResult>(
          success: false,
          message: 'Unexpected login response format',
          error: ApiError(message: 'Unexpected login response format'),
        );
      }

      final envelope =
          body['data'] is Map<String, dynamic> ? body['data'] as Map<String, dynamic> : body;
      final success = body['success'] as bool? ?? true;
      final message = (body['message'] ?? '').toString();

      if (!success) {
        final errorMap = body['error'] is Map<String, dynamic>
            ? body['error'] as Map<String, dynamic>
            : null;
        return ApiResponse<AuthResult>(
          success: false,
          message: message,
          error: errorMap != null
              ? ApiError.fromJson(errorMap)
              : ApiError(message: message.isNotEmpty ? message : 'Login failed'),
        );
      }

      final parsed = _parseLoginPayload(envelope);
      if (parsed.error != null) {
        return ApiResponse<AuthResult>(
          success: false,
          message: parsed.error!,
          error: ApiError(message: parsed.error!),
        );
      }

      await _tokenStorage.saveToken(parsed.token!);
      return ApiResponse<AuthResult>(
        success: true,
        message: message,
        data: AuthResult(
          userId: parsed.userId!,
          username: parsed.username!,
          role: parsed.role!,
        ),
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        final message = (responseData['message'] ??
                responseData['error']?['message'] ??
                e.message ??
                'Login failed')
            .toString();
        return ApiResponse<AuthResult>(
          success: false,
          message: message,
          error: ApiError(
            message: message,
            details: responseData['error'] ?? responseData,
          ),
        );
      }

      return ApiResponse<AuthResult>(
        success: false,
        message: e.message ?? 'Login failed',
        error: ApiError(message: e.message ?? 'Login failed'),
      );
    }
  }

  @override
  Future<ApiResponse<User>> getCurrentUser() async {
    final response = await _apiClient.get<UserResponse>(
      '/auth/me',
      fromJsonT: (json) => UserResponse.fromJson(json),
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      return ApiResponse<User>(
        success: true,
        message: response.message,
        data: User(
          id: data.id,
          employeeCode: data.employeeCode,
          fullName: data.fullName,
          email: data.email,
          role: data.role,
          isActive: data.isActive,
          lastLoginAt: data.lastLoginAt,
          createdAt: data.createdAt,
          updatedAt: data.updatedAt,
        ),
      );
    }

    return ApiResponse<User>(
      success: false,
      message: response.message,
      error: response.error,
    );
  }

  @override
  Future<ApiResponse<void>> changePassword(
      {required String currentPassword, required String newPassword}) async {
    final response = await _apiClient.post<void>(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );

    if (response.success) {
      return ApiResponse<void>(
        success: true,
        message: response.message,
      );
    }

    return ApiResponse<void>(
      success: false,
      message: response.message,
      error: response.error,
    );
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }
}

class _ParsedLoginPayload {
  final String? token;
  final String? userId;
  final String? username;
  final String? role;
  final String? error;

  const _ParsedLoginPayload({
    this.token,
    this.userId,
    this.username,
    this.role,
    this.error,
  });
}

_ParsedLoginPayload _parseLoginPayload(Map<String, dynamic> data) {
  final user = data['user'] is Map<String, dynamic>
      ? data['user'] as Map<String, dynamic>
      : const <String, dynamic>{};
  final token = (data['token'] ?? data['accessToken'] ?? '').toString();
  final userId = (user['id'] ?? data['userId'] ?? '').toString();
  final username = (user['username'] ??
          user['name'] ??
          user['fullName'] ??
          data['username'] ??
          '')
      .toString();
  final role = (user['role'] ?? data['role'] ?? '').toString();

  if (token.isEmpty) {
    return const _ParsedLoginPayload(error: 'Login token missing in response');
  }

  if (userId.isEmpty || username.isEmpty || role.isEmpty) {
    return const _ParsedLoginPayload(
      error: 'Login response is missing user details',
    );
  }

  return _ParsedLoginPayload(
    token: token,
    userId: userId,
    username: username,
    role: role,
  );
}
