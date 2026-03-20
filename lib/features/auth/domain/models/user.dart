class User {
  final String id;
  final String employeeCode;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
  });
}
