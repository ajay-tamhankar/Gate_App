import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../features/gate_entry/presentation/controllers/gate_entry_controller.dart';
import '../../features/reconciliation/presentation/controllers/import_history_controller.dart';
import '../../features/reconciliation/presentation/controllers/reco_list_controller.dart';
import '../../features/reconciliation/presentation/controllers/reconciliation_security_controller.dart';
import '../../features/sap/presentation/controllers/grn_upload_provider.dart';
import '../../features/warehouse/presentation/controllers/warehouse_providers.dart';

void clearOrgScopedState(Ref ref) {
  ref.invalidate(currentUserProvider);
  ref.invalidate(dashboardControllerProvider);
  ref.invalidate(gateEntryControllerProvider);
  ref.invalidate(reconciliationSecurityControllerProvider);
  ref.invalidate(reconciliationFilterProvider);
  ref.invalidate(recoListControllerProvider);
  ref.invalidate(importHistoryProvider);
  ref.invalidate(grnUploadProvider);
  ref.invalidate(warehouseGateEntriesProvider);
  ref.invalidate(warehouseDashboardProvider);
  ref.invalidate(warehouseGateEntryVerificationControllerProvider);
  ref.invalidate(warehouseGateEntryManagerActionControllerProvider);
  ref.invalidate(warehouseReconciliationSummaryProvider);
  ref.invalidate(warehouseManagerReconciliationsProvider);
  ref.invalidate(reconciliationDashboardProvider);
  ref.invalidate(warehouseManagerDashboardSummaryProvider);
  ref.invalidate(warehouseManagerAdminKpiProvider);
  ref.invalidate(warehouseReconciliationActionControllerProvider);
  ref.invalidate(warehouseGrnControllerProvider);
}

void scheduleOrgScopedStateClear(Ref ref) {
  // Delay invalidation until after logout-driven navigation has a chance to
  // unmount authenticated screens. Immediate invalidation can re-run provider
  // builds while those screens are still listening.
  unawaited(
    Future<void>.delayed(const Duration(milliseconds: 32), () {
      clearOrgScopedState(ref);
    }),
  );
}
