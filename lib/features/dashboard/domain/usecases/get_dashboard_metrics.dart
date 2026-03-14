import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_dashboard_repository.dart';
import '../entities/dashboard_metrics.dart';
import '../dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return MockDashboardRepository(); // Real implementation later
});

final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getMetrics();
});
