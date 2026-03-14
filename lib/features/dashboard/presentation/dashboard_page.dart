import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';
import '../domain/usecases/get_dashboard_metrics.dart';
import '../../../core/ui/responsive.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider.notifier).authedOrNull;
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: metricsAsync.when(
        data: (metrics) {
          final isMob = isMobile(context);
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(dashboardMetricsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(
                  'Welcome back, ${session?.userId ?? "User"} (${session?.role ?? ""})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),

                // Summary Cards
                GridView.count(
                  crossAxisCount: isMob ? 2 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isMob ? 1.4 : 1.8,
                  children: [
                    _StatCard(
                      title: 'Entries (Today/Month)',
                      value:
                          '${metrics.totalGateEntriesToday} / ${metrics.totalGateEntriesMonth}',
                      icon: Icons.local_shipping,
                      color: Colors.blue,
                    ),
                    _StatCard(
                      title: 'Total GRN Posted',
                      value: metrics.totalGrnPosted.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: 'Pending GRN',
                      value: metrics.pendingGrnCount.toString(),
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                    ),
                    _StatCard(
                      title: 'Qty Mismatch',
                      value: metrics.quantityMismatchCases.toString(),
                      icon: Icons.warning_amber_rounded,
                      color: Colors.redAccent,
                    ),
                    _StatCard(
                      title: 'Duplicate GRN',
                      value: metrics.duplicateGrnCases.toString(),
                      icon: Icons.copy_all,
                      color: Colors.red,
                    ),
                    _StatCard(
                      title: 'Matched Grn',
                      value: metrics.matchedDraws.toString(),
                      icon: Icons.check_circle_outline,
                      color: Colors.teal,
                    ),
                    _StatCard(
                      title: 'Pending Reco',
                      value: metrics.pendingReconciliations.toString(),
                      icon: Icons.hourglass_empty,
                      color: Colors.amber,
                    ),
                    _StatCard(
                      title: 'Exceptions',
                      value: metrics.exceptionsRaised.toString(),
                      icon: Icons.error_outline,
                      color: Colors.deepOrange,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // TAT and Aging Section
                if (isMob)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTatCard(context, metrics),
                      const SizedBox(height: 16),
                      _buildAgingCard(context, metrics),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTatCard(context, metrics)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildAgingCard(context, metrics)),
                    ],
                  ),

                const SizedBox(height: 32),
                Text('Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),

                // Chart Placeholder / List
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: metrics.recentActivity.map((activity) {
                          const maxEntries = 40.0;
                          final rawHeight =
                              (activity.entriesCount / maxEntries) * 150;
                          final height = rawHeight.clamp(0.0, 150.0);

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(activity.entriesCount.toString(),
                                  style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 4),
                              Container(
                                width: isMob ? 20 : 40,
                                height: height,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha((255 * 0.7).round()),
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(activity.day,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildTatCard(BuildContext context, dynamic metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Turnaround Time (TAT)',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.timer, color: Colors.blue),
              title: const Text('GATE TAT'),
              trailing: Text('${metrics.gateTat} mins',
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            ListTile(
              leading: const Icon(Icons.dock, color: Colors.blueGrey),
              title: const Text('Dock TAT'),
              trailing: Text('${metrics.dockTat} mins',
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgingCard(BuildContext context, dynamic metrics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aging of Pending GRN',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.date_range, color: Colors.lightGreen),
              title: const Text('0-1 Day'),
              trailing: Text('${metrics.pendingGrnAging0To1}',
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            ListTile(
              leading: const Icon(Icons.date_range, color: Colors.orange),
              title: const Text('2-3 Days'),
              trailing: Text('${metrics.pendingGrnAging2To3}',
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            ListTile(
              leading: const Icon(Icons.date_range, color: Colors.red),
              title: const Text('> 3 Days'),
              trailing: Text('${metrics.pendingGrnAgingMoreThan3}',
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
