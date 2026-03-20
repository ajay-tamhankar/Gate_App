import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import '../../../core/ui/widgets/status_chip.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../../gate_entry/presentation/gate_entry_detail_page.dart';
import '../domain/entities/reconciliation_item.dart';
import 'controllers/reconciliation_security_controller.dart';

class ReconciliationSecurityView extends ConsumerStatefulWidget {
  const ReconciliationSecurityView({super.key});

  @override
  ConsumerState<ReconciliationSecurityView> createState() =>
      _ReconciliationSecurityViewState();
}

class _ReconciliationSecurityViewState
    extends ConsumerState<ReconciliationSecurityView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reconciliationSecurityControllerProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    if (role != UserRole.gateSecurity) {
      return const SizedBox.shrink();
    }

    final asyncItems = ref.watch(reconciliationSecurityControllerProvider);
    final filter = ref.watch(reconciliationFilterProvider);
    final isMob = isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(reconciliationSecurityControllerProvider.notifier)
                .refresh(),
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: asyncItems.when(
        loading: () => _buildLoading(context, isMob),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          return RefreshIndicator(
            onRefresh: () async => ref
                .read(reconciliationSecurityControllerProvider.notifier)
                .refresh(),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildFilterRow(context, ref, filter),
                const SizedBox(height: 16),
                _buildSummary(context, items, isMob),
                const SizedBox(height: 16),
                _buildExceptionBanner(context, items),
                const SizedBox(height: 16),
                items.isEmpty
                    ? _buildEmptyState(context)
                    : isMob
                        ? _buildMobileList(context, items)
                        : _buildDesktopTable(context, items),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterRow(
      BuildContext context, WidgetRef ref, ReconciliationFilterState filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last7 = today.subtract(const Duration(days: 6));

    final isToday = filter.dateFrom == today &&
        filter.dateTo == today.add(const Duration(days: 1));
    final isLast7 = filter.dateFrom == last7 &&
        filter.dateTo == today.add(const Duration(days: 1));

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilterChip(
          label: const Text('Today'),
          selected: isToday,
          onSelected: (_) {
            ref.read(reconciliationFilterProvider.notifier).state =
                ReconciliationFilterState(
              dateFrom: today,
              dateTo: today.add(const Duration(days: 1)),
            );
            ref
                .read(reconciliationSecurityControllerProvider.notifier)
                .refresh();
          },
        ),
        FilterChip(
          label: const Text('Last 7 days'),
          selected: isLast7,
          onSelected: (_) {
            ref.read(reconciliationFilterProvider.notifier).state =
                ReconciliationFilterState(
              dateFrom: last7,
              dateTo: today.add(const Duration(days: 1)),
            );
            ref
                .read(reconciliationSecurityControllerProvider.notifier)
                .refresh();
          },
        ),
        TextButton(
          onPressed: () {
            ref.read(reconciliationFilterProvider.notifier).state =
                const ReconciliationFilterState();
            ref
                .read(reconciliationSecurityControllerProvider.notifier)
                .refresh();
          },
          child: const Text('Clear'),
        ),
      ],
    );
  }

  Widget _buildSummary(
      BuildContext context, List<ReconciliationItem> items, bool isMob) {
    final matched = _countByStatus(items, 'matched');
    final pending = _countByStatus(items, 'pending');
    final exception = _countByStatus(items, 'exception');

    final cards = [
      _summaryCard(
          context, 'Matched', matched, Icons.check_circle, Colors.green),
      _summaryCard(
          context, 'Pending', pending, Icons.pending_actions, Colors.orange),
      _summaryCard(context, 'Exception', exception, Icons.warning_amber_rounded,
          Colors.red),
    ];

    final cardHeight = isMob ? 60.0 : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: SizedBox(height: cardHeight, child: cards[0])),
        const SizedBox(width: 0),
        Expanded(child: SizedBox(height: cardHeight, child: cards[1])),
        const SizedBox(width: 0),
        Expanded(child: SizedBox(height: cardHeight, child: cards[2])),
      ],
    );
  }

  Widget _summaryCard(BuildContext context, String title, int value,
      IconData icon, Color color) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(2),
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
        padding: const EdgeInsets.all(8.0),
        child: FittedBox(
          // 🔥 ONLY CHANGE (forces horizontal fit)
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExceptionBanner(
      BuildContext context, List<ReconciliationItem> items) {
    final exceptionCount = _countByStatus(items, 'exception');
    if (exceptionCount == 0) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: Colors.red.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '? $exceptionCount entries have reconciliation issues',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileList(
      BuildContext context, List<ReconciliationItem> items) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => _openDetail(context, item),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outlineVariant
                      .withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.gateEntryNo.isNotEmpty
                        ? item.gateEntryNo
                        : item.gateEntryId,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statusChip(item.status),
                      const SizedBox(width: 8),
                      Text(_formatDate(item.date)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(
      BuildContext context, List<ReconciliationItem> items) {
    return DataTable2(
      columnSpacing: 12,
      horizontalMargin: 12,
      columns: const [
        DataColumn(label: Text('Gate Entry No')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Date')),
      ],
      rows: items.map((item) {
        return DataRow(
          onSelectChanged: (_) => _openDetail(context, item),
          cells: [
            DataCell(Text(item.gateEntryNo.isNotEmpty
                ? item.gateEntryNo
                : item.gateEntryId)),
            DataCell(_statusChip(item.status)),
            DataCell(Text(_formatDate(item.date))),
          ],
        );
      }).toList(),
    );
  }

  Widget _statusChip(String status) {
    final key = status.toLowerCase();
    if (key.contains('match')) {
      return const StatusChip(label: 'Matched', color: Colors.green);
    }
    if (key.contains('pending')) {
      return const StatusChip(label: 'Pending', color: Colors.orange);
    }
    if (key.contains('exception') || key.contains('mismatch')) {
      return const StatusChip(label: 'Exception', color: Colors.red);
    }
    return StatusChip(
        label: status.isNotEmpty ? status : 'Unknown', color: Colors.grey);
  }

  int _countByStatus(List<ReconciliationItem> items, String type) {
    return items.where((i) {
      final key = i.status.toLowerCase();
      if (type == 'matched') return key.contains('match');
      if (type == 'pending') return key.contains('pending');
      return key.contains('exception') || key.contains('mismatch');
    }).length;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 40, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(
              'No reconciliation records found.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context, bool isMob) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SkeletonLoader(width: double.infinity, height: 80),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SkeletonLoader(
                width: double.infinity,
                height: isMob ? 90 : 120,
              ),
            ),
            if (!isMob) ...[
              const SizedBox(width: 12),
              const Expanded(
                child: SkeletonLoader(width: double.infinity, height: 120),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: SkeletonLoader(width: double.infinity, height: 120),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        const SkeletonLoader(width: double.infinity, height: 240),
      ],
    );
  }

  void _openDetail(BuildContext context, ReconciliationItem item) {
    final id = item.gateEntryId.isNotEmpty ? item.gateEntryId : item.id;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GateEntryDetailPage(entryId: id),
      ),
    );
  }
}
