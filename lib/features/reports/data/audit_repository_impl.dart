import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/entities/audit_log.dart';
import '../domain/audit_repository.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepositoryImpl(apiClient: ref.read(apiClientProvider));
});

class AuditRepositoryImpl implements AuditRepository {
  final ApiClient _apiClient;

  AuditRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<void> logAction(String userId, String role, String module,
      String action, String description) async {
    await _apiClient.post<void>(
      '/audit-logs',
      data: {
        'userId': userId,
        'role': role,
        'module': module,
        'action': action,
        'description': description,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  @override
  Future<List<AuditLog>> getLogs(
      {DateTime? startDate, DateTime? endDate}) async {
    final query = <String, dynamic>{};
    if (startDate != null) {
      query['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      query['endDate'] = endDate.toIso8601String();
    }

    final response = await _apiClient.getRaw(
      '/audit-logs',
      queryParameters: query.isEmpty ? null : query,
    );

    final success = response['success'] as bool? ?? false;
    if (!success) return [];

    final data = response['data'];
    final list = data is List ? data : (response['items'] as List? ?? []);

    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return AuditLog(
        userId: map['userId']?.toString() ?? '',
        role: map['role']?.toString() ?? '',
        module: map['module']?.toString() ?? '',
        action: map['action']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }
}
