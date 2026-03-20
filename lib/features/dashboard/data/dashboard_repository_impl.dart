import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dashboard_repository.dart';
import '../domain/entities/dashboard_metrics.dart';
import 'dashboard_api.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(api: ref.read(dashboardApiProvider));
});

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardApi _api;

  DashboardRepositoryImpl({required DashboardApi api}) : _api = api;

  @override
  Future<DashboardMetrics> getMetrics() async {
    final response = await _api.fetchMetrics();
    if (response.success && response.data != null) {
      return response.data!;
    }
    final message = response.error?.message.isNotEmpty == true
        ? response.error!.message
        : response.message;
    throw Exception(message.isNotEmpty ? message : 'Failed to load metrics');
  }
}
