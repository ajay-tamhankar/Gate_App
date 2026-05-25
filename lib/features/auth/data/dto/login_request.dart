class LoginRequest {
  final String organizationCode;
  final String? email;
  final String? username;
  final String password;
  final bool rememberMe;

  const LoginRequest({
    required this.organizationCode,
    this.email,
    this.username,
    required this.password,
    this.rememberMe = false,
  });

  factory LoginRequest.fromIdentifier({
    required String organizationCode,
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) {
    final trimmedIdentifier = identifier.trim();
    final isEmail = trimmedIdentifier.contains('@');

    return LoginRequest(
      organizationCode: organizationCode.trim(),
      email: isEmail ? trimmedIdentifier : null,
      username: isEmail ? null : trimmedIdentifier,
      password: password,
      rememberMe: rememberMe,
    );
  }

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      organizationCode: (json['organizationCode'] ?? '').toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      password: (json['password'] ?? '').toString(),
      rememberMe: json['rememberMe'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'organizationCode': organizationCode,
      if (email?.trim().isNotEmpty == true) 'email': email,
      if (username?.trim().isNotEmpty == true) 'username': username,
      'password': password,
      'rememberMe': rememberMe,
    };
  }
}
