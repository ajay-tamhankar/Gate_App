import 'entities/audit_log.dart';

abstract class AuditRepository {
  Future<void> logAction(String userId, String role, String module,
      String action, String description);
  Future<List<AuditLog>> getLogs({DateTime? startDate, DateTime? endDate});
}
