import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dashboard_repository_impl.dart';
import '../entities/dashboard_metrics.dart';

final dashboardMetricsProvider = FutureProvider<DashboardMetrics>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.getMetrics();
});
