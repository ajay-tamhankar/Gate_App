import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../../gate_entry/data/gate_entry_repository_impl.dart';
import '../../../gate_entry/domain/models/gate_entry.dart';
import '../../../../core/auth/session_controller.dart';
import '../../../../core/auth/session_state.dart';
import '../../../../core/auth/user_role.dart';

class DashboardController extends AsyncNotifier<DashboardMetrics> {
  @override
  Future<DashboardMetrics> build() async {
    final session = ref.read(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;

    if (role == UserRole.gateSecurity) {
      return _buildGateSecurityMetrics();
    }

    final repository = ref.watch(dashboardRepositoryProvider);
    return repository.getMetrics();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = ref.read(sessionControllerProvider);
      final role = session is Authenticated ? session.role : null;

      if (role == UserRole.gateSecurity) {
        return _buildGateSecurityMetrics();
      }

      final repository = ref.read(dashboardRepositoryProvider);
      return repository.getMetrics();
    });
  }

  Future<DashboardMetrics> _buildGateSecurityMetrics() async {
    final repo = ref.read(gateEntryRepositoryProvider);
    final response = await repo.getGateEntries(page: 1, limit: 100);
    final entries = response.data?.items ?? const <GateEntry>[];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);

    int todayCount = 0;
    int monthCount = 0;
    int aging0To1 = 0;
    int aging2To3 = 0;
    int agingMoreThan3 = 0;

    for (final e in entries) {
      final ts = e.gateTimestamp;
      if (ts == null) continue;
      final tsDate = DateTime(ts.year, ts.month, ts.day);

      if (!tsDate.isBefore(monthStart)) {
        monthCount++;
      }
      if (tsDate == today) {
        todayCount++;
      }

      final ageDays = now.difference(ts).inDays;
      if (_isPendingForAging(e.status)) {
        if (ageDays <= 1) {
          aging0To1++;
        } else if (ageDays <= 3) {
          aging2To3++;
        } else {
          agingMoreThan3++;
        }
      }
    }

    final recentActivity = _buildRecentActivity(entries, now);

    return DashboardMetrics(
      totalGateEntriesToday: todayCount,
      totalGateEntriesMonth: monthCount,
      totalGrnPosted: 0,
      pendingGrnCount: 0,
      quantityMismatchCases: 0,
      duplicateGrnCases: 0,
      gateTat: 0,
      dockTat: 0,
      pendingGrnAging0To1: aging0To1,
      pendingGrnAging2To3: aging2To3,
      pendingGrnAgingMoreThan3: agingMoreThan3,
      recentActivity: recentActivity,
    );
  }

  bool _isPendingForAging(String status) {
    final s = status.toLowerCase();
    return s == 'inward_created' ||
        s == 'verification_pending' ||
        s == 'approved' ||
        s == 'pending';
  }

  List<DailyActivity> _buildRecentActivity(
      List<GateEntry> entries, DateTime now) {
    final formatter = DateFormat('EEE');
    final days = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return DateTime(day.year, day.month, day.day);
    });

    final counts = <String, int>{};
    for (final d in days) {
      counts[formatter.format(d)] = 0;
    }

    for (final e in entries) {
      final ts = e.gateTimestamp;
      if (ts == null) continue;
      final d = DateTime(ts.year, ts.month, ts.day);
      final key = formatter.format(d);
      if (counts.containsKey(key)) {
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }

    return counts.entries
        .map((e) => DailyActivity(day: e.key, entriesCount: e.value))
        .toList();
  }
}

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardMetrics>(
  DashboardController.new,
);

