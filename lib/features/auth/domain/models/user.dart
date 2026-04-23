import 'organization.dart';

class User {
  final String id;
  final String organizationId;
  final String? employeeCode;
  final String fullName;
  final String email;
  final String role;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Organization? organization;

  User({
    required this.id,
    required this.organizationId,
    required this.employeeCode,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isActive,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
    this.organization,
  });
}
