class AuthResult {
  final String userId;
  final String role;
  final String accessToken;
  final String? refreshToken;

  AuthResult({
    required this.userId,
    required this.role,
    required this.accessToken,
    this.refreshToken,
  });
}
