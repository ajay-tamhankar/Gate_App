import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/auth/session_state.dart';
import '../../../../core/auth/session_controller.dart';
import '../../../../core/network/dio_provider.dart';
import '../../../dashboard/domain/entities/dashboard_metrics.dart';
import '../../../gate_entry/data/gate_entry_repository_impl.dart';
import '../../../gate_entry/domain/models/gate_entry.dart';
import '../../data/warehouse_repository_impl.dart';
import '../../domain/models/warehouse_dashboard_metrics.dart';
import '../../domain/models/warehouse_gate_entry.dart';
import '../../domain/models/warehouse_grn.dart';
import '../../domain/models/warehouse_reconciliation.dart';
import '../../domain/models/reconciliation_dashboard.dart';
import '../../domain/warehouse_repository.dart';
import '../../../reconciliation/domain/reconciliation_period_filter.dart';

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
  // Filter out those that have already gated out for the executive overview
  final pendingEntries = entries.where((e) => e.gateOutTimestamp == null).toList();
  
  return WarehouseDashboardMetrics(
    pendingGrnCount: pendingEntries.length,
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
  final records = await repo.getReconciliations(
    filter: ReconciliationPeriodFilter.today,
  );
  int matched = 0;
  int pending = 0;
  int exception = 0;
  for (final record in records) {
    if (record.isMatched) {
      matched++;
    } else if (record.isException) {
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
  final items = await repo.getReconciliations(
    filter: ReconciliationPeriodFilter.today,
  );
  return items.where((item) => item.isActive).toList();
});


final reconciliationDashboardProvider =
    FutureProvider.autoDispose<ReconciliationDashboardData>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.getRaw(
    '/reconciliations',
    queryParameters: const {'filter': 'today'},
  );

  final success = response['success'] as bool? ?? false;
  if (!success) {
    throw Exception(
      response['message']?.toString() ??
          'Failed to load reconciliation dashboard data',
    );
  }
  return ReconciliationDashboardData.fromApiResponse(response);
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

bool _statusContainsAny(String value, List<String> needles) {
  final s = value.toLowerCase();
  for (final n in needles) {
    if (s.contains(n)) return true;
  }
  return false;
}

bool _isPendingGrnStatus(String status) {
  return _statusContainsAny(status, ['pending grn', 'grn pending', 'pending_grn']);
}

bool _isDuplicateGrnStatus(String status) {
  return _statusContainsAny(status, ['duplicate grn', 'duplicate']);
}

bool _isQuantityMismatchStatus(String status) {
  return _statusContainsAny(
      status, ['quantity mismatch', 'qty mismatch', 'quantity_mismatch']);
}

bool _isGrnPostedStatus(String status) {
  // We treat "posted"/"completed"/"closed" as GRN posted.
  return _statusContainsAny(status, ['grn posted', 'posted', 'completed', 'closed']);
}

final warehouseManagerAdminKpiProvider =
    FutureProvider.autoDispose<DashboardMetrics>((ref) async {
  final gateRepo = ref.read(gateEntryRepositoryProvider);
  final warehouseRepo = ref.read(warehouseRepositoryProvider);

  final resp = await gateRepo.getGateEntries();
  if (!resp.success || resp.data == null) {
    final msg = resp.error?.message.isNotEmpty == true
        ? resp.error!.message
        : resp.message;
    throw Exception(msg.isNotEmpty ? msg : 'Failed to load gate entries');
  }
  final allEntries = resp.data!.items;

  // ---- Fetch reconciliation records ----
  final recoRecords = await warehouseRepo.getReconciliations();

  final now = DateTime.now();

  int todayCount = 0;
  int monthCount = 0;
  int gateIn = 0;
  int gateOut = 0;

  for (final e in allEntries) {
    final isExited = e.gateOutTimestamp != null;
    if (e.gateMovement == GateMovement.inMovement && !isExited) {
      gateIn++;
    } else if (e.gateMovement == GateMovement.outMovement || isExited) {
      gateOut++;
    }

    final ts = e.gateTimestamp?.toLocal();
    final todayString = DateFormat('yyyy-MM-dd').format(now);
    final monthString = DateFormat('yyyy-MM').format(now);
    
    bool isToday = false;
    bool isMonth = false;

    if (ts != null) {
      final dStr = DateFormat('yyyy-MM-dd').format(ts);
      if (dStr == todayString) isToday = true;
      if (dStr.startsWith(monthString)) isMonth = true;
    }

    if (e.gateOutTimestamp != null) {
      final outTs = e.gateOutTimestamp!.toLocal();
      final dStr = DateFormat('yyyy-MM-dd').format(outTs);
      if (dStr == todayString) isToday = true;
      if (dStr.startsWith(monthString)) isMonth = true;
    }

    if (isToday) todayCount++;
    if (isMonth) monthCount++;
  }

  int totalGrnPosted = 0;
  int pendingGrnCount = 0;
  int qtyMismatch = 0;
  int duplicateGrn = 0;

  int aging0To1 = 0;
  int aging2To3 = 0;
  int agingMoreThan3 = 0;

  for (final r in recoRecords) {
    final status = r.status;
    final normalized = status.toLowerCase();

    if (_isGrnPostedStatus(normalized)) totalGrnPosted++;
    if (_isPendingGrnStatus(normalized) || r.isPending) pendingGrnCount++;
    if (_isQuantityMismatchStatus(normalized) || r.isException) qtyMismatch++;
    if (_isDuplicateGrnStatus(normalized)) duplicateGrn++;

    // Aging buckets apply to pending GRN only.
    if (_isPendingGrnStatus(normalized) || (r.isPending && !_isGrnPostedStatus(normalized))) {
      final base = r.date?.toLocal();
      if (base != null) {
        final days = now.difference(base).inDays;
        if (days <= 1) {
          aging0To1++;
        } else if (days <= 3) {
          aging2To3++;
        } else {
          agingMoreThan3++;
        }
      }
    }
  }

  // TAT requires backend workflow timestamps; keep 0 until available.
  const gateTat = 0.0;
  const dockTat = 0.0;

  return DashboardMetrics(
    totalGateEntriesToday: todayCount,
    totalGateEntriesMonth: monthCount,
    gateInCount: gateIn,
    gateOutCount: gateOut,
    totalGrnPosted: totalGrnPosted,
    pendingGrnCount: pendingGrnCount,
    quantityMismatchCases: qtyMismatch,
    duplicateGrnCases: duplicateGrn,
    gateTat: gateTat,
    dockTat: dockTat,
    pendingGrnAging0To1: aging0To1,
    pendingGrnAging2To3: aging2To3,
    pendingGrnAgingMoreThan3: agingMoreThan3,
    recentActivity: const [],
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
