import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import 'controllers/dashboard_controller.dart';
import '../domain/entities/dashboard_metrics.dart';
import '../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../auth/domain/models/user.dart';
import '../../auth/presentation/change_password_page.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/stat_card.dart';
import '../../../core/ui/widgets/dashboard_chart.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import '../../../core/ui/widgets/logout_action.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Authenticated? session =
        ref.watch(sessionControllerProvider.notifier).authedOrNull;
    final metricsAsync = ref.watch(dashboardControllerProvider);
    final userAsync = ref.watch(currentUserProvider);
    final role = session?.role;
    final isGateSecurity = role == UserRole.gateSecurity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operations Dashboard'),
        actions: [
          if (session?.role == UserRole.admin)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordPage(),
                  ),
                );
              },
              icon: const Icon(Icons.lock_reset),
              label: const Text('Change Password'),
            ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: metricsAsync.when(
        data: (metrics) {
          final isMob = isMobile(context);
          return RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                ref.refresh(dashboardControllerProvider.future),
                ref.refresh(currentUserProvider.future),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SectionHeader(
                  title: 'Welcome back, ${_displayName(userAsync, session)}',
                  subtitle:
                      'Role: ${_displayRole(userAsync, session)} - ${_displayLogin(userAsync, session)}',
                ),

                // Summary Cards
                Builder(
                  builder: (context) {
                    final cards = <Widget>[
                      StatCard(
                        title: 'Entries (Today/Month)',
                        value:
                            '${metrics.totalGateEntriesToday} / ${metrics.totalGateEntriesMonth}',
                        icon: Icons.local_shipping,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      StatCard(
                        title: 'Total GRN Posted',
                        value: metrics.totalGrnPosted.toString(),
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      StatCard(
                        title: 'Pending GRN',
                        value: metrics.pendingGrnCount.toString(),
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                      StatCard(
                        title: 'Qty Mismatch',
                        value: metrics.quantityMismatchCases.toString(),
                        icon: Icons.warning_amber_rounded,
                        color: Colors.redAccent,
                      ),
                      StatCard(
                        title: 'Duplicate GRN',
                        value: metrics.duplicateGrnCases.toString(),
                        icon: Icons.copy_all,
                        color: Colors.red,
                      ),
                      // StatCard(
                      //   title: 'Gate TAT',
                      //   value: '${metrics.gateTat.toStringAsFixed(0)} mins',
                      //   icon: Icons.timer,
                      //   color: Colors.blue,
                      // ),
                      // StatCard(
                      //   title: 'Dock TAT',
                      //   value: '${metrics.dockTat.toStringAsFixed(0)} mins',
                      //   icon: Icons.dock,
                      //   color: Colors.blueGrey,
                      // ),
                    ];

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: isMob ? 200 : 260,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: isMob ? 1.2 : 2.2,
                      ),
                      itemCount: cards.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) => cards[index],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // TAT and Aging Section
                if (isMob)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildActivityChart(context, metrics),
                      const SizedBox(height: 16),
                      _buildTatCard(context, metrics),
                      const SizedBox(height: 16),
                      _buildAgingCard(context, metrics),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildActivityChart(context, metrics),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTatCard(context, metrics),
                            const SizedBox(height: 16),
                            _buildAgingCard(context, metrics),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () {
          final isMob = isMobile(context);
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SkeletonLoader(width: 250, height: 40),
              const SizedBox(height: 24),
              Row(children: [
                const Expanded(
                    child: SkeletonLoader(width: double.infinity, height: 120)),
                const SizedBox(width: 16),
                const Expanded(
                    child: SkeletonLoader(width: double.infinity, height: 120)),
                if (!isMob) ...[
                  const SizedBox(width: 16),
                  const Expanded(
                      child:
                          SkeletonLoader(width: double.infinity, height: 120)),
                  const SizedBox(width: 16),
                  const Expanded(
                      child:
                          SkeletonLoader(width: double.infinity, height: 120)),
                ]
              ]),
              const SizedBox(height: 32),
              const SkeletonLoader(width: double.infinity, height: 300),
            ],
          );
        },
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildActivityChart(BuildContext context, DashboardMetrics metrics) {
    if (metrics.recentActivity.isEmpty) {
      return const SizedBox.shrink();
    }
    final List<ChartBarData> chartData =
        metrics.recentActivity.map<ChartBarData>((a) {
      return ChartBarData(
        label: a.day,
        value: a.entriesCount.toDouble(),
        color: Theme.of(context).colorScheme.primary,
      );
    }).toList();

    final isMob = isMobile(context);
    return DashboardChart(
      title: 'Gate Entry Activity (Last 7 Days)',
      data: chartData,
      height: isMob ? 260 : 350,
    );
  }

  Widget _buildTatCard(BuildContext context, DashboardMetrics metrics) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Turnaround Time (TAT)',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildInfoRow(context, Icons.timer, Colors.blue, 'GATE TAT',
                '${metrics.gateTat} mins'),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.dock, Colors.blueGrey, 'DOCK TAT',
                '${metrics.dockTat} mins'),
          ],
        ),
      ),
    );
  }

  Widget _buildAgingCard(BuildContext context, DashboardMetrics metrics) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Aging of Pending GRN',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildInfoRow(context, Icons.date_range, Colors.green, '0-1 Day',
                '${metrics.pendingGrnAging0To1}'),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.date_range, Colors.orange, '2-3 Days',
                '${metrics.pendingGrnAging2To3}'),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.date_range, Colors.red, '> 3 Days',
                '${metrics.pendingGrnAgingMoreThan3}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, Color color,
      String title, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  String _displayName(AsyncValue<User> userAsync, Authenticated? session) {
    return userAsync.when(
      data: (user) {
        if (user.fullName.isNotEmpty) {
          return user.fullName;
        }
        if (user.email.isNotEmpty) {
          return user.email;
        }
        return session?.userId ?? 'User';
      },
      loading: () => session?.userId ?? 'User',
      error: (_, __) => session?.userId ?? 'User',
    );
  }

  String _displayRole(AsyncValue<User> userAsync, Authenticated? session) {
    return userAsync.when(
      data: (user) => user.role.isNotEmpty
          ? (UserRole.fromApi(user.role)?.label ?? user.role)
          : (session?.role.label ?? 'Operator'),
      loading: () => session?.role.label ?? 'Operator',
      error: (_, __) => session?.role.label ?? 'Operator',
    );
  }

  String _displayLogin(AsyncValue<User> userAsync, Authenticated? session) {
    return userAsync.when(
      data: (user) {
        final parts = <String>[];
        if (user.employeeCode.isNotEmpty) {
          parts.add(user.employeeCode);
        }
        if (user.email.isNotEmpty) {
          parts.add(user.email);
        }
        if (parts.isNotEmpty) {
          return 'Logged in as ${parts.join(' • ')}';
        }
        return 'Logged in as ${session?.userId ?? 'User'}';
      },
      loading: () => 'Logged in as ${session?.userId ?? 'User'}',
      error: (_, __) => 'Logged in as ${session?.userId ?? 'User'}',
    );
  }
}
