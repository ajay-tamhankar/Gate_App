class AuditLog {
  final String userId;
  final String role;
  final String module;
  final String action;
  final String description;
  final DateTime timestamp;

  AuditLog({
    required this.userId,
    required this.role,
    required this.module,
    required this.action,
    required this.description,
    required this.timestamp,
  });
}
