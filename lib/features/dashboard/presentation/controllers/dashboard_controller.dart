import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_metrics.dart';
import '../../../gate_entry/data/gate_entry_repository_impl.dart';
import '../../../gate_entry/domain/models/gate_entry.dart';
import '../../../gate_entry/domain/models/gate_entry_summary.dart';
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
    final response = await repo.getGateEntries();
    final listResponse = response.data;
    final entries = listResponse?.items ?? const <GateEntry>[];
    final summary = listResponse?.summary;

    final now = DateTime.now();

    int totalCount = 0;
    int todayCount = 0;
    int yesterdayCount = 0;
    int thisWeekCount = 0;
    int monthCount = 0;
    int gateInCount = 0;
    int gateOutCount = 0;
    double gateTat = 0;
    double dockTat = 0;
    int aging0To1 = 0;
    int aging2To3 = 0;
    int agingMoreThan3 = 0;

    for (final e in entries) {
      final rawTs = e.gateTimestamp;
      if (rawTs == null) continue;

      final tsLocal = rawTs.toLocal();
      final ageDays = now.difference(tsLocal).inDays;
      if (_isPendingForAging(e.status) && e.gateOutTimestamp == null) {
        if (ageDays <= 1) {
          aging0To1++;
        } else if (ageDays <= 3) {
          aging2To3++;
        } else {
          agingMoreThan3++;
        }
      }
    }

    if (_hasGateEntrySummary(summary)) {
      totalCount = summary!.total;
      todayCount = summary.today;
      yesterdayCount = summary.yesterday;
      thisWeekCount = summary.thisWeek;
      monthCount = summary.thisMonth;
      gateInCount = summary.gateIn;
      gateOutCount = summary.gateOut;
      gateTat = summary.gateTat;
      dockTat = summary.dockTat;
    } else {
      // DateFormat instances are expensive — build once, reuse for every row.
      final dayFmt = DateFormat('yyyy-MM-dd');
      final monthFmt = DateFormat('yyyy-MM');
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final weekStart = today.subtract(Duration(days: now.weekday - 1));
      final todayString = dayFmt.format(today);
      final yesterdayString = dayFmt.format(yesterday);
      final monthStartString = monthFmt.format(today);

      for (final e in entries) {
        final isExited = e.gateOutTimestamp != null;
        totalCount++;
        if (e.gateMovement == GateMovement.inMovement && !isExited) {
          gateInCount++;
        } else if (e.gateMovement == GateMovement.outMovement || isExited) {
          gateOutCount++;
        }

        final rawTs = e.gateTimestamp;
        if (rawTs == null) continue;

        final tsLocal = rawTs.toLocal();
        final tsDateString = dayFmt.format(tsLocal);

        if (tsDateString.startsWith(monthStartString)) {
          monthCount++;
        } else if (e.gateOutTimestamp != null) {
          final outDateString = monthFmt.format(e.gateOutTimestamp!.toLocal());
          if (outDateString == monthStartString) {
            monthCount++;
          }
        }

        if (tsDateString == todayString) {
          todayCount++;
        } else if (tsDateString == yesterdayString) {
          yesterdayCount++;
        } else if (e.gateOutTimestamp != null) {
          final outDateString = dayFmt.format(e.gateOutTimestamp!.toLocal());
          if (outDateString == todayString) {
            todayCount++;
          } else if (outDateString == yesterdayString) {
            yesterdayCount++;
          }
        }

        final entryDay = DateTime(tsLocal.year, tsLocal.month, tsLocal.day);
        if (!entryDay.isBefore(weekStart)) {
          thisWeekCount++;
        } else if (e.gateOutTimestamp != null) {
          final outLocal = e.gateOutTimestamp!.toLocal();
          final outDay = DateTime(outLocal.year, outLocal.month, outLocal.day);
          if (!outDay.isBefore(weekStart)) {
            thisWeekCount++;
          }
        }
      }
    }

    final recentActivity = _buildRecentActivity(entries, now);

    return DashboardMetrics(
      totalGateEntriesOverall: totalCount,
      totalGateEntriesToday: todayCount,
      totalGateEntriesYesterday: yesterdayCount,
      totalGateEntriesThisWeek: thisWeekCount,
      totalGateEntriesMonth: monthCount,
      gateInCount: gateInCount,
      gateOutCount: gateOutCount,
      totalGrnPosted: 0,
      pendingGrnCount: 0,
      quantityMismatchCases: 0,
      duplicateGrnCases: 0,
      gateTat: gateTat,
      dockTat: dockTat,
      pendingGrnAging0To1: aging0To1,
      pendingGrnAging2To3: aging2To3,
      pendingGrnAgingMoreThan3: agingMoreThan3,
      recentActivity: recentActivity,
    );
  }

  bool _hasGateEntrySummary(GateEntrySummary? summary) {
    if (summary == null) return false;
    return summary.total > 0 ||
        summary.gateIn > 0 ||
        summary.gateOut > 0 ||
        summary.gatedOut > 0 ||
        summary.today > 0 ||
        summary.yesterday > 0 ||
        summary.thisWeek > 0 ||
        summary.thisMonth > 0 ||
        summary.gateTat > 0 ||
        summary.dockTat > 0;
  }

  static const _pendingAgingStatuses = {
    'inward_created',
    'verification_pending',
    'approved',
    'pending',
  };

  bool _isPendingForAging(String status) {
    return _pendingAgingStatuses.contains(status.toLowerCase());
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
      final tsLocal = e.gateTimestamp?.toLocal();
      if (tsLocal == null) continue;
      final d = DateTime(tsLocal.year, tsLocal.month, tsLocal.day);
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

