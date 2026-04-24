import '../../../core/network/api_response.dart';
import '../data/dto/login_request.dart';
import 'models/auth_result.dart';
import 'models/user.dart';

abstract class AuthRepository {
  Future<ApiResponse<AuthResult>> login(LoginRequest request);
  Future<ApiResponse<User>> getCurrentUser();
  Future<ApiResponse<void>> changePassword(
      {required String currentPassword, required String newPassword});
  Future<void> logout();
}
