import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import 'controllers/warehouse_providers.dart';
import '../domain/models/warehouse_reconciliation.dart';

class WarehouseDashboardPage extends ConsumerWidget {
  const WarehouseDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final isManager =
        role == UserRole.warehouseManager || role == UserRole.whMgr;
    final isMob = isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isManager ? 'Manager Dashboard' : 'Warehouse Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(warehouseDashboardProvider);
              ref.invalidate(warehouseReconciliationSummaryProvider);
              ref.invalidate(warehouseManagerDashboardSummaryProvider);
              ref.invalidate(warehouseManagerReconciliationsProvider);
            },
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: isManager
          ? _ManagerDashboard(isMob: isMob)
          : _ExecutiveDashboard(isMob: isMob),
    );
  }
}

class _ExecutiveDashboard extends ConsumerWidget {
  final bool isMob;

  const _ExecutiveDashboard({required this.isMob});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(warehouseDashboardProvider);
    final recSummary = ref.watch(warehouseReconciliationSummaryProvider);

    return metrics.when(
      loading: () => ListView(
        padding:
            EdgeInsets.symmetric(horizontal: isMob ? 16 : 24, vertical: 16),
        children: const [
          SkeletonLoader(width: 220, height: 28),
          SizedBox(height: 16),
          SkeletonLoader(width: double.infinity, height: 120),
          SizedBox(height: 16),
          SkeletonLoader(width: double.infinity, height: 120),
        ],
      ),
      error: (e, _) => Center(child: Text('Failed to load dashboard: $e')),
      data: (data) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: isMob ? 16 : 24, vertical: 16),
          children: [
            SectionHeader(
              title: 'Today Overview',
              subtitle: 'Track pending GRNs and incoming entries quickly.',
              trailing: TextButton.icon(
                onPressed: () => context.go('/app/gate-entry'),
                icon: const Icon(Icons.list_alt),
                label: const Text('View Pending GRNs'),
              ),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(
                  title: 'Pending GRNs',
                  value: data.pendingGrnCount.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  width: isMob ? double.infinity : 220,
                ),
                _StatCard(
                  title: "Today's Entries",
                  value: data.todaysEntries.toString(),
                  icon: Icons.local_shipping,
                  color: Colors.indigo,
                  width: isMob ? double.infinity : 220,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Reconciliation Snapshot (Today)',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildReconciliationSection(context, recSummary, isMob),
          ],
        );
      },
    );
  }

  Widget _buildReconciliationSection(
    BuildContext context,
    AsyncValue<WarehouseReconciliationSummary> summary,
    bool isMob,
  ) {
    return summary.when(
      loading: () => const SkeletonLoader(width: double.infinity, height: 110),
      error: (e, _) => Text(
        'Failed to load reconciliation: $e',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      data: (data) => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _StatCard(
            title: 'Matched',
            value: data.matched.toString(),
            icon: Icons.check_circle,
            color: Colors.green,
            width: isMob ? double.infinity : 180,
          ),
          _StatCard(
            title: 'Pending',
            value: data.pending.toString(),
            icon: Icons.hourglass_bottom,
            color: Colors.orange,
            width: isMob ? double.infinity : 180,
          ),
          _StatCard(
            title: 'Exception',
            value: data.exception.toString(),
            icon: Icons.error,
            color: Colors.red,
            width: isMob ? double.infinity : 180,
          ),
        ],
      ),
    );
  }
}

class _ManagerDashboard extends ConsumerWidget {
  final bool isMob;

  const _ManagerDashboard({required this.isMob});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(warehouseManagerDashboardSummaryProvider);

    return summary.when(
      loading: () => ListView(
        padding:
            EdgeInsets.symmetric(horizontal: isMob ? 16 : 24, vertical: 16),
        children: const [
          SkeletonLoader(width: 220, height: 28),
          SizedBox(height: 16),
          SkeletonLoader(width: double.infinity, height: 120),
          SizedBox(height: 16),
          SkeletonLoader(width: double.infinity, height: 120),
        ],
      ),
      error: (e, _) => Center(child: Text('Failed to load dashboard: $e')),
      data: (data) {
        return ListView(
          padding: EdgeInsets.symmetric(horizontal: isMob ? 16 : 24, vertical: 16),
          children: [
            SectionHeader(
              title: 'Approval Overview',
              subtitle: 'Review reconciled entries and finalize the workflow.',
              trailing: TextButton.icon(
                onPressed: () => context.go('/app/reconciliation'),
                icon: const Icon(Icons.rule_folder),
                label: const Text('Open Review Queue'),
              ),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _StatCard(
                  title: 'Pending Approval',
                  value: data.pendingApproval.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  width: isMob ? double.infinity : 220,
                ),
                _StatCard(
                  title: 'Exceptions',
                  value: data.exceptions.toString(),
                  icon: Icons.error_outline,
                  color: Colors.red,
                  width: isMob ? double.infinity : 220,
                ),
                _StatCard(
                  title: 'Approved Today',
                  value: data.approvedToday.toString(),
                  icon: Icons.verified,
                  color: Colors.blue,
                  width: isMob ? double.infinity : 220,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}