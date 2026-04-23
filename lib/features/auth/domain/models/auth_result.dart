import 'organization.dart';
import 'user.dart';

class AuthResult {
  final String accessToken;
  final String role;
  final User user;
  final Organization organization;

  AuthResult({
    required this.accessToken,
    required this.role,
    required this.user,
    required this.organization,
  });

  String get userId => user.id;
  String get username => user.employeeCode ?? user.email;
  String get fullName => user.fullName;
}
