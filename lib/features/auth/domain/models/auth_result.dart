import 'organization.dart';
import 'user.dart';

class AuthResult {
  final String accessToken;
  final String role;
  final User user;
  final Organization organization;
  final bool rememberMe;

  AuthResult({
    required this.accessToken,
    required this.role,
    required this.user,
    required this.organization,
    this.rememberMe = false,
  });

  String get userId => user.id;
  String get username => user.employeeCode ?? user.email;
  String get fullName => user.fullName;
}
