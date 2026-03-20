import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/session_state.dart';
import '../../../../core/auth/session_controller.dart';
import '../../data/warehouse_repository_impl.dart';
import '../../domain/models/warehouse_dashboard_metrics.dart';
import '../../domain/models/warehouse_gate_entry.dart';
import '../../domain/models/warehouse_grn.dart';
import '../../domain/models/warehouse_reconciliation.dart';
import '../../domain/warehouse_repository.dart';

final warehouseGateEntriesProvider =
    FutureProvider.autoDispose<List<WarehouseGateEntrySummary>>((ref) async {
  final repo = ref.read(warehouseRepositoryProvider);
  return repo.getGateEntries();
});

final warehouseDashboardProvider =
    FutureProvider.autoDispose<WarehouseDashboardMetrics>((ref) async {
  final entries = await ref.watch(warehouseGateEntriesProvider.future);
  final now = DateTime.now();
  final today = DateFormat('yyyy-MM-dd').format(now);
  final todayCount = entries.where((e) {
    if (e.entryTime == null) return false;
    return DateFormat('yyyy-MM-dd').format(e.entryTime!) == today;
  }).length;
  return WarehouseDashboardMetrics(
    pendingGrnCount: entries.length,
    todaysEntries: todayCount,
  );
});

final warehouseGateEntryDetailProvider = FutureProvider.autoDispose
    .family<WarehouseGateEntryDetail, String>((ref, id) async {
  final repo = ref.read(warehouseRepositoryProvider);
  return repo.getGateEntryDetail(id);
});

class WarehouseGateEntryVerificationController
    extends StateNotifier<AsyncValue<void>> {
  WarehouseGateEntryVerificationController(this._repo)
      : super(const AsyncData(null));

  final WarehouseRepository _repo;

  Future<bool> verifyEntry(
    String id,
    WarehouseGateEntryVerificationRequest request,
  ) async {
    state = const AsyncLoading();
    try {
      await _repo.verifyGateEntry(id, request);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final warehouseGateEntryVerificationControllerProvider = StateNotifierProvider
    .autoDispose<WarehouseGateEntryVerificationController, AsyncValue<void>>(
        (ref) {
  final repo = ref.read(warehouseRepositoryProvider);
  return WarehouseGateEntryVerificationController(repo);
});


class WarehouseGateEntryManagerActionController
    extends StateNotifier<AsyncValue<void>> {
  WarehouseGateEntryManagerActionController(this._repo)
      : super(const AsyncData(null));

  final WarehouseRepository _repo;

  Future<bool> approve(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.approveGateEntry(id);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> close(String id) async {
    state = const AsyncLoading();
    try {
      await _repo.closeGateEntry(id);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final warehouseGateEntryManagerActionControllerProvider =
    StateNotifierProvider.autoDispose<WarehouseGateEntryManagerActionController,
        AsyncValue<void>>((ref) {
  final repo = ref.read(warehouseRepositoryProvider);
  return WarehouseGateEntryManagerActionController(repo);
});
final warehouseReconciliationSummaryProvider =
    FutureProvider.autoDispose<WarehouseReconciliationSummary>((ref) async {
  final repo = ref.read(warehouseRepositoryProvider);
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end =
      start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
  final records = await repo.getReconciliations(dateFrom: start, dateTo: end);
  int matched = 0;
  int pending = 0;
  int exception = 0;
  for (final record in records) {
    final status = record.status.toLowerCase();
    if (status.contains('match')) {
      matched++;
    } else if (status.contains('exception') || status.contains('mismatch')) {
      exception++;
    } else {
      pending++;
    }
  }
  return WarehouseReconciliationSummary(
    matched: matched,
    pending: pending,
    exception: exception,
  );
});

final warehouseManagerReconciliationsProvider =
    FutureProvider.autoDispose<List<WarehouseReconciliationRecord>>((ref) async {
  final repo = ref.read(warehouseRepositoryProvider);
  final items = await repo.getReconciliations();
  return items.where((item) => item.isActive).toList();
});

final warehouseManagerDashboardSummaryProvider =
    FutureProvider.autoDispose<WarehouseManagerDashboardSummary>((ref) async {
  final records = await ref.watch(warehouseManagerReconciliationsProvider.future);
  final now = DateTime.now();
  final today = DateFormat('yyyy-MM-dd').format(now);

  final pendingApproval = records
      .where((item) => item.isMatched || item.isException)
      .length;
  final exceptions = records.where((item) => item.isException).length;
  final approvedToday = records.where((item) {
    if (!item.isApproved || item.date == null) return false;
    return DateFormat('yyyy-MM-dd').format(item.date!) == today;
  }).length;

  return WarehouseManagerDashboardSummary(
    pendingApproval: pendingApproval,
    exceptions: exceptions,
    approvedToday: approvedToday,
  );
});

class WarehouseReconciliationActionController
    extends StateNotifier<AsyncValue<void>> {
  WarehouseReconciliationActionController(this._repo)
      : super(const AsyncData(null));

  final WarehouseRepository _repo;

  Future<bool> approve(
    String id,
    WarehouseReconciliationActionRequest request,
  ) async {
    state = const AsyncLoading();
    try {
      await _repo.approveReconciliation(id, request);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> close(
    String id,
    WarehouseReconciliationActionRequest request,
  ) async {
    state = const AsyncLoading();
    try {
      await _repo.closeReconciliation(id, request);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final warehouseReconciliationActionControllerProvider = StateNotifierProvider
    .autoDispose<WarehouseReconciliationActionController, AsyncValue<void>>(
        (ref) {
  final repo = ref.read(warehouseRepositoryProvider);
  return WarehouseReconciliationActionController(repo);
});

final warehouseManagerUserIdProvider = Provider.autoDispose<String?>((ref) {
  final session = ref.watch(sessionControllerProvider);
  return session is Authenticated ? session.userId : null;
});

class WarehouseGrnController extends StateNotifier<AsyncValue<void>> {
  WarehouseGrnController(this._repo) : super(const AsyncData(null));

  final WarehouseRepository _repo;

  Future<bool> submitGrn(WarehouseGrnRequest request) async {
    state = const AsyncLoading();
    try {
      await _repo.createGrn(request);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final warehouseGrnControllerProvider =
    StateNotifierProvider.autoDispose<WarehouseGrnController, AsyncValue<void>>(
        (ref) {
  final repo = ref.read(warehouseRepositoryProvider);
  return WarehouseGrnController(repo);
});
