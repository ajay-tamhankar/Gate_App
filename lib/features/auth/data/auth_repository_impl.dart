import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    apiClient: ref.read(apiClientProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  @override
  Future<ApiResponse<AuthResult>> login(LoginRequest request) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
      fromJsonT: (json) => json is Map<String, dynamic>
          ? json
          : <String, dynamic>{},
    );

    if (!response.success || response.data == null) {
      return ApiResponse<AuthResult>(
        success: false,
        message: response.message,
        error: response.error,
      );
    }

    final message = response.message;
    final data = response.data!;
    final token = (data['token'] ?? data['accessToken'] ?? '').toString();
    final user = data['user'] as Map<String, dynamic>? ?? {};
    final userId = (user['id'] ?? data['userId'] ?? '').toString();
    final username =
        (user['name'] ?? user['fullName'] ?? data['username'] ?? '').toString();
    final role = (user['role'] ?? data['role'] ?? '').toString();

    if (token.isEmpty) {
      return ApiResponse<AuthResult>(
        success: false,
        message: 'Login token missing in response',
        error: ApiError(message: 'Login token missing'),
      );
    }

    await _tokenStorage.saveToken(token);
    return ApiResponse<AuthResult>(
      success: true,
      message: message,
      data: AuthResult(
        userId: userId,
        username: username,
        role: role,
      ),
    );
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
