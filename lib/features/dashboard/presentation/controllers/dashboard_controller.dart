import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_metrics.dart';

class DashboardController extends AsyncNotifier<DashboardMetrics> {
  @override
  Future<DashboardMetrics> build() {
    final repository = ref.watch(dashboardRepositoryProvider);
    return repository.getMetrics();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() {
      final repository = ref.read(dashboardRepositoryProvider);
      return repository.getMetrics();
    });
  }
}

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardMetrics>(
  DashboardController.new,
);
