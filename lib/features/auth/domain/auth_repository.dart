import 'models/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String username, String password);
  Future<AuthResult> refreshSession();
  Future<void> logout();
}
