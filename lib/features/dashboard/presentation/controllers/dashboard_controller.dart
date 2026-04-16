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

    final entries = <GateEntry>[];
    var page = 1;
    const limit = 200;

    while (true) {
      final response = await repo.getGateEntries(page: page, limit: limit);
      final pageItems = response.data?.items ?? const <GateEntry>[];
      entries.addAll(pageItems);

      final pagination = response.data?.pagination;
      if (pagination == null ||
          !pagination.hasNext ||
          page >= pagination.totalPages) {
        break;
      }

      page++;
      if (page > 25) break; // safety cap for very large datasets
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nowUtc = now.toUtc();
    final todayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final monthStart = DateTime(now.year, now.month, 1);

    int todayCount = 0;
    int monthCount = 0;
    int gateInCount = 0;
    int gateOutCount = 0;
    int aging0To1 = 0;
    int aging2To3 = 0;
    int agingMoreThan3 = 0;

    for (final e in entries) {
      final isExited = e.gateOutTimestamp != null;
      if (e.gateMovement == GateMovement.inMovement && !isExited) {
        gateInCount++;
      } else if (e.gateMovement == GateMovement.outMovement || isExited) {
        gateOutCount++;
      }

      final rawTs = e.gateTimestamp;
      if (rawTs == null) continue;

      final tsLocal = rawTs.toLocal();
      final tsDateString = DateFormat('yyyy-MM-dd').format(tsLocal);
      final todayString = DateFormat('yyyy-MM-dd').format(now);
      final monthStartString = DateFormat('yyyy-MM').format(now);

      if (tsDateString.startsWith(monthStartString)) {
        monthCount++;
      } else if (e.gateOutTimestamp != null) {
        final outDateString = DateFormat('yyyy-MM').format(e.gateOutTimestamp!.toLocal());
        if (outDateString == monthStartString) {
          monthCount++;
        }
      }

      if (tsDateString == todayString) {
        todayCount++;
      } else if (e.gateOutTimestamp != null) {
        final outDateString = DateFormat('yyyy-MM-dd').format(e.gateOutTimestamp!.toLocal());
        if (outDateString == todayString) {
          todayCount++;
        }
      }

      // Special case: if it gated out TODAY, it should also be counted in today's entry activity?
      // Actually "Entries" usually means arrivals. But if the user says it shows 2/7 while 
      // they see 5 In and 4 Out, let's ensure we are not missing anything.
      
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

    final recentActivity = _buildRecentActivity(entries, now);

    return DashboardMetrics(
      totalGateEntriesToday: todayCount,
      totalGateEntriesMonth: monthCount,
      gateInCount: gateInCount,
      gateOutCount: gateOutCount,
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

