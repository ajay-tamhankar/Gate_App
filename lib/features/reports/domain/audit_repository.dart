import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'entities/audit_log.dart';

abstract class AuditRepository {
  Future<void> logAction(String userId, String role, String module,
      String action, String description);
  Future<List<AuditLog>> getLogs({DateTime? startDate, DateTime? endDate});
}

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return MockAuditRepository();
});

class MockAuditRepository implements AuditRepository {
  final List<AuditLog> _logs = [];

  @override
  Future<void> logAction(String userId, String role, String module,
      String action, String description) async {
    _logs.add(
      AuditLog(
        userId: userId,
        role: role,
        module: module,
        action: action,
        description: description,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<AuditLog>> getLogs(
      {DateTime? startDate, DateTime? endDate}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var filtered = List<AuditLog>.from(_logs);
    if (startDate != null) {
      filtered = filtered.where((l) => l.timestamp.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      filtered = filtered.where((l) => l.timestamp.isBefore(endDate)).toList();
    }
    // Newest first
    filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return filtered;
  }
}
