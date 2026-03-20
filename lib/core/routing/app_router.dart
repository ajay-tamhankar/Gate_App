import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/warehouse/presentation/warehouse_dashboard_page.dart';
import '../../features/gate_entry/presentation/gate_entry_page.dart';
import '../../features/warehouse/presentation/warehouse_gate_entry_list_page.dart';
import '../../features/warehouse/presentation/warehouse_reconciliation_list_page.dart';
import '../../features/reconciliation/presentation/reco_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../auth/session_controller.dart';
import '../auth/user_role.dart';
import '../auth/session_state.dart';
import '../ui/widgets/app_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);

      final goingToLogin = state.matchedLocation == '/login';
      final authed = session is Authenticated;

      if (!authed && !goingToLogin) return '/login';
      if (authed && goingToLogin) return '/app/dashboard';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(
            selectedIndex: _indexFromLocation(state.matchedLocation),
            onSelect: (i) {
              switch (i) {
                case 0:
                  context.go('/app/dashboard');
                  break;
                case 1:
                  context.go('/app/gate-entry');
                  break;
                case 2:
                  context.go('/app/reconciliation');
                  break;
                case 3:
                  context.go('/app/reports');
                  break;
              }
            },
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/app/dashboard',
            builder: (context, state) {
              final session = ref.read(sessionControllerProvider);
              final role = session is Authenticated ? session.role : null;
              if (role == UserRole.warehouseExecutive ||
                  role == UserRole.warehouseManager ||
                  role == UserRole.whMgr) {
                return const WarehouseDashboardPage();
              }
              return const DashboardPage();
            },
          ),
          GoRoute(
            path: '/app/gate-entry',
            builder: (context, state) {
              final session = ref.read(sessionControllerProvider);
              final role = session is Authenticated ? session.role : null;
              if (role == UserRole.warehouseExecutive ||
                  role == UserRole.warehouseManager ||
                  role == UserRole.whMgr) {
                return const WarehouseGateEntryListPage();
              }
              return const GateEntryPage();
            },
          ),
          GoRoute(
            path: '/app/reconciliation',
            builder: (context, state) {
              final session = ref.read(sessionControllerProvider);
              final role = session is Authenticated ? session.role : null;
              if (role == UserRole.warehouseManager || role == UserRole.whMgr) {
                return const WarehouseReconciliationListPage();
              }
              return const RecoPage();
            },
          ),
          GoRoute(
            path: '/app/reports',
            builder: (context, state) => const ReportsPage(),
          ),
        ],
      ),
    ],
  );
});

int _indexFromLocation(String location) {
  if (location.startsWith('/app/gate-entry')) return 1;
  if (location.startsWith('/app/reconciliation')) return 2;
  if (location.startsWith('/app/reports')) return 3;
  return 0;
}

/// Forces router refresh when session changes
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this.ref) {
    ref.listen<SessionState>(
      sessionControllerProvider,
      (_, __) => notifyListeners(),
    );
  }
  final Ref ref;
}

