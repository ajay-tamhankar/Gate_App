import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/session_controller.dart';
import '../../../core/auth/session_state.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/filter_bar.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../../../core/ui/widgets/skeleton_loader.dart';
import '../domain/models/gate_entry.dart';
import 'controllers/gate_entry_controller.dart';
import 'gate_entry_detail_page.dart';
import 'gate_entry_form_page.dart';

import '../../warehouse/domain/models/warehouse_gate_entry.dart';
import '../../warehouse/presentation/controllers/warehouse_providers.dart';
import '../../../core/ui/widgets/section_header.dart';
import '../../../core/ui/widgets/status_chip.dart';

class GateEntryPage extends ConsumerWidget {
  const GateEntryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    
    // For exec, show the pending GRN view. Otherwise show the standard operations view.
    if (role == UserRole.warehouseExecutive) {
      return const _WarehouseGateEntryView();
    }
    return const _GateEntrySecurityView();
  }
}

class _GateEntrySecurityView extends ConsumerStatefulWidget {
  const _GateEntrySecurityView({super.key});

  @override
  ConsumerState<_GateEntrySecurityView> createState() => _GateEntrySecurityViewState();
}

class _GateEntrySecurityViewState extends ConsumerState<_GateEntrySecurityView> {
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gateEntryControllerProvider.notifier).fetchEntries(refresh: true);
    });
  }

  /// Returns true if the entry's gateTimestamp falls on [date]
  bool _isOnDate(GateEntry e, DateTime date, {bool includeExit = false}) {
    final t = e.gateTimestamp?.toLocal();
    final todayStr = DateFormat('yyyy-MM-dd').format(date);
    
    if (t != null && DateFormat('yyyy-MM-dd').format(t) == todayStr) {
      return true;
    }
    
    if (includeExit && e.gateOutTimestamp != null) {
      final outT = e.gateOutTimestamp!.toLocal();
      if (DateFormat('yyyy-MM-dd').format(outT) == todayStr) {
        return true;
      }
    }
    
    return false;
  }

  List<GateEntry> _applyFilters(List<GateEntry> entries) {
    final query = _searchQuery.toLowerCase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    return entries.where((e) {
      final matchesSearch = query.isEmpty ||
          e.challanNo.toLowerCase().contains(query) ||
          e.vendorName.toLowerCase().contains(query) ||
          e.vendorCode.toLowerCase().contains(query) ||
          e.lrNumber.toLowerCase().contains(query) ||
          e.driverContactNo.toLowerCase().contains(query) ||
          e.transporterName.toLowerCase().contains(query) ||
          e.vehicleNo.toLowerCase().contains(query);

      final bool matchesStatus;
      switch (_statusFilter) {
        case 'Gate In':
          // Only show those that are "In" and HAVEN'T gone out yet
          matchesStatus = e.gateMovement == GateMovement.inMovement && e.gateOutTimestamp == null;
          break;
        case 'Gate Out':
          // Show those that are "Out" entries OR "In" entries that HAVE gone out
          matchesStatus = e.gateMovement == GateMovement.outMovement || e.gateOutTimestamp != null;
          break;
        case 'Today':
          matchesStatus = _isOnDate(e, today);
          break;
        case 'Yesterday':
          matchesStatus = _isOnDate(e, yesterday);
          break;
        case 'This Week':
          final t = e.gateTimestamp?.toLocal();
          matchesStatus =
              t != null && !t.isBefore(weekStart) && t.isBefore(today.add(const Duration(days: 1)));
          break;
        default:
          matchesStatus = true;
      }

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gateEntryControllerProvider);
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final canCreate = role == UserRole.gateSecurity;
    final isMob = isMobile(context);
    final isTab = isTablet(context);

    final filtered = _applyFilters(state.entries);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gate Entry Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(gateEntryControllerProvider.notifier)
                .fetchEntries(refresh: true),
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const GateEntryFormPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Gate Entry'),
            )
          : null,
      body: state.isLoading && state.entries.isEmpty
          ? _buildLoadingView(isMob, isTab)
          : Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => ref
                      .read(gateEntryControllerProvider.notifier)
                      .fetchEntries(refresh: true),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = constraints.maxWidth > 1440
                          ? 1440.0
                          : constraints.maxWidth;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: SizedBox(
                          width: contentWidth,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMob ? 16 : 24,
                              vertical: isMob ? 16 : 24,
                            ),
                            children: [
                              _buildHeroSection(
                                context,
                                filtered: filtered,
                                total: state.pagination?.total ?? state.entries.length,
                                canCreate: canCreate,
                                isCompact: isMob,
                              ),
                              const SizedBox(height: 16),
                              _buildSummarySection(context, filtered, state.entries, isMob, isTab),
                              const SizedBox(height: 16),
                              _buildFilters(context, filtered.length, isMob),
                              if (state.error != null) ...[
                                const SizedBox(height: 12),
                                _buildErrorBanner(context, state.error!),
                              ],
                              const SizedBox(height: 16),
                              filtered.isEmpty
                                  ? _buildEmptyState(context)
                                  : isMob
                                      ? _buildMobileList(filtered)
                                      : _buildDesktopTable(filtered, isTab),
                              const SizedBox(height: 12),
                              _buildPaginationSection(context, state),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (state.isLoading && state.entries.isNotEmpty)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      minHeight: 2,
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildLoadingView(bool isMob, bool isTab) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isMob ? 16 : 24,
        vertical: isMob ? 16 : 24,
      ),
      children: [
        const SkeletonLoader(width: double.infinity, height: 150),
        const SizedBox(height: 16),
        if (isMob)
          const SkeletonLoader(width: double.infinity, height: 100)
        else
          Row(
            children: [
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 88 : 100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 88 : 100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 88 : 100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeletonLoader(
                  width: double.infinity,
                  height: isTab ? 88 : 100,
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        const SkeletonLoader(width: double.infinity, height: 88),
        const SizedBox(height: 16),
        const SkeletonLoader(width: double.infinity, height: 420),
      ],
    );
  }

  Widget _buildHeroSection(
    BuildContext context, {
    required List<GateEntry> filtered,
    required int total,
    required bool canCreate,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 18 : 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.blueGrey.shade900,
            Colors.indigo.shade700,
            Colors.teal.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroContent(
                  context,
                  filtered: filtered.length,
                  total: total,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildHeroContent(
                    context,
                    filtered: filtered.length,
                    total: total,
                  ),
                ),
                if (canCreate) ...[
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GateEntryFormPage(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blueGrey.shade900,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('New Gate Entry'),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildHeroContent(
    BuildContext context, {
    required int filtered,
    required int total,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Warehouse Gate Control',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Track vehicle arrivals, challans, LR numbers, and approvals in one place.',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _heroMetric('Showing', '$filtered'),
            _heroMetric('Total', '$total'),
          ],
        ),
      ],
    );
  }

  Widget _heroMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    List<GateEntry> filtered,
    List<GateEntry> all,
    bool isMob,
    bool isTab,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final gateInCount = filtered
        .where((e) =>
            e.gateMovement == GateMovement.inMovement &&
            e.gateOutTimestamp == null)
        .length;
    final gateOutCount = filtered.length - gateInCount;
    final todayCount = all.where((e) => _isOnDate(e, today, includeExit: true)).length;
    final yesterdayCount = all.where((e) => _isOnDate(e, yesterday, includeExit: true)).length;

    final cards = [
      _summaryCard(
        context,
        title: 'Gate In',
        value: '$gateInCount',
        subtitle: 'Incoming vehicles',
        icon: Icons.login,
        accent: Colors.indigo,
      ),
      _summaryCard(
        context,
        title: 'Gate Out',
        value: '$gateOutCount',
        subtitle: 'Outgoing vehicles',
        icon: Icons.logout,
        accent: Colors.deepOrange,
      ),
      _summaryCard(
        context,
        title: 'Today',
        value: '$todayCount',
        subtitle: 'Entries today',
        icon: Icons.today,
        accent: Colors.teal,
      ),
      _summaryCard(
        context,
        title: 'Yesterday',
        value: '$yesterdayCount',
        subtitle: 'Entries yesterday',
        icon: Icons.history,
        accent: Colors.purple,
      ),
    ];

    if (isMob) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 10),
          Expanded(child: cards[1]),
        ],
      );
    }

    // Tablet / Desktop: 4 cards in a row
    return Row(
      children: [
        Expanded(child: cards[0]),
        SizedBox(width: isTab ? 10 : 12),
        Expanded(child: cards[1]),
        SizedBox(width: isTab ? 10 : 12),
        Expanded(child: cards[2]),
        SizedBox(width: isTab ? 10 : 12),
        Expanded(child: cards[3]),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, int count, bool isMob) {
    return FilterBar(
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '$count records',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
      children: [
        SizedBox(
          width: isMob ? double.infinity : 320,
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search challan, LR, vendor, vehicle',
              prefixIcon: const Icon(Icons.search, size: 18),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        SizedBox(
          width: isMob ? double.infinity : 220,
          child: DropdownButtonFormField<String>(
            initialValue: _statusFilter,
            decoration: InputDecoration(
              labelText: 'Filter',
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Gate In', child: Text('Gate In')),
              DropdownMenuItem(value: 'Gate Out', child: Text('Gate Out')),
              DropdownMenuItem(value: 'Today', child: Text('Today')),
              DropdownMenuItem(value: 'Yesterday', child: Text('Yesterday')),
              DropdownMenuItem(value: 'This Week', child: Text('This Week')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _statusFilter = val);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationSection(BuildContext context, GateEntryState state) {
    final pagination = state.pagination;
    if (pagination == null) return const SizedBox.shrink();

    final loaded = state.entries.length;
    final total = pagination.total;
    final hasNext = pagination.hasNext;

    return Column(
      children: [
        Text(
          'Loaded $loaded of $total entries',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        if (hasNext)
          OutlinedButton.icon(
            onPressed: state.isLoading
                ? null
                : () => ref.read(gateEntryControllerProvider.notifier).fetchEntries(
                      page: pagination.page + 1,
                      limit: pagination.limit,
                    ),
            icon: state.isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.expand_more),
            label: Text(state.isLoading ? 'Loading...' : 'Load More'),
          )
        else
          Text(
            'All entries loaded',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
      ],
    );
  }

  String _vendorLabel(GateEntry entry) {
    return entry.vendorCode.isEmpty
        ? entry.vendorName
        : '${entry.vendorName} (${entry.vendorCode})';
  }

  String _transporterLabel(GateEntry entry) {
    return entry.transporterName;
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('dd MMM yy • hh:mm a').format(timestamp.toLocal());
  }

  // ─── Mobile List ──────────────────────────────────────────────────────────

  Widget _buildMobileList(List<GateEntry> entries) {
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _MobileEntryCard(
          entry: entry,
          role: role,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GateEntryDetailPage(entryId: entry.id),
            ),
          ),
          onVerify: () => _confirmAndAct(
            context,
            title: 'Verify Entry',
            message: 'Verify this gate entry?',
            action: () => ref
                .read(gateEntryControllerProvider.notifier)
                .verifyEntry(entry.id),
          ),
          onApprove: () => _confirmAndAct(
            context,
            title: 'Approve Entry',
            message: 'Approve this gate entry?',
            action: () => ref
                .read(gateEntryControllerProvider.notifier)
                .approveEntry(entry.id),
          ),
          onClose: () => _confirmAndAct(
            context,
            title: 'Close Entry',
            message: 'Close this gate entry?',
            action: () => ref
                .read(gateEntryControllerProvider.notifier)
                .closeEntry(entry.id),
          ),
          formatTimestamp: _formatTimestamp,
          vendorLabel: _vendorLabel,
        );
      },
    );
  }

  // ─── Desktop Table ────────────────────────────────────────────────────────

  Widget _buildDesktopTable(List<GateEntry> entries, bool isTab) {
    return SizedBox(
      height: 560,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(context)
                .colorScheme
                .outlineVariant
                .withValues(alpha: 0.5),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: DataTable2(
            columnSpacing: isTab ? 10 : 14,
            horizontalMargin: isTab ? 16 : 24,
            minWidth: 1280,
            headingRowHeight: 60,
            dataRowHeight: 68,
            showCheckboxColumn: false,
            columns: const [
              DataColumn2(label: Text('Direction'), size: ColumnSize.S),
              DataColumn2(label: Text('Challan No'), size: ColumnSize.M),
              DataColumn2(label: Text('LR Number'), size: ColumnSize.M),
              DataColumn2(label: Text('Material'), size: ColumnSize.S),
              DataColumn2(
                  label: Text('Qty'), size: ColumnSize.S, numeric: true),
              DataColumn2(label: Text('Vendor'), size: ColumnSize.L),
              DataColumn2(label: Text('Transporter'), size: ColumnSize.L),
              DataColumn2(label: Text('Vehicle No'), size: ColumnSize.M),
              DataColumn2(label: Text('Entry Time'), size: ColumnSize.M),
            ],
            rows: entries.map((entry) {
              final isExited = entry.gateOutTimestamp != null;
              final isGateIn = entry.gateMovement == GateMovement.inMovement;
              
              // If it has exited, we show "Gate Out" icon/text regardless of movement type
              final effectiveDirectionIcon = (isExited || !isGateIn) ? Icons.logout : Icons.login;
              final effectiveDirectionColor = (isExited || !isGateIn) ? Colors.deepOrange : Colors.indigo;
              final effectiveDirectionLabel = (isExited || !isGateIn) ? 'Gate Out' : 'Gate In';
              final materialCode =
                  entry.items.isNotEmpty ? entry.items.first.materialCode : '-';
              final qty = entry.items.isNotEmpty
                  ? entry.items.fold(0, (sum, i) => sum + i.challanQty)
                  : 0;

              return DataRow(
                onSelectChanged: (_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GateEntryDetailPage(entryId: entry.id),
                    ),
                  );
                },
                cells: [
                  DataCell(
                    Row(
                      children: [
                        Icon(
                          effectiveDirectionIcon,
                          size: 18,
                          color: effectiveDirectionColor,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            effectiveDirectionLabel,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Text(
                      entry.challanNo,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  DataCell(Text(entry.lrNumber.isEmpty ? '-' : entry.lrNumber)),
                  DataCell(Text(materialCode)),
                  DataCell(
                    Text(
                      qty.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  DataCell(Text(_vendorLabel(entry))),
                  DataCell(Text(_transporterLabel(entry))),
                  DataCell(
                    Text(entry.vehicleNo.isEmpty ? '-' : entry.vehicleNo),
                  ),
                  DataCell(Text(_formatTimestamp(entry.gateTimestamp))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_shipping_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No gate entries found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try changing the search text or filter to see more records.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }



  Future<void> _confirmAndAct(
    BuildContext context, {
    required String title,
    required String message,
    required Future<bool> Function() action,
  }) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (proceed != true) return;
    final success = await action();
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action completed'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      ref
          .read(gateEntryControllerProvider.notifier)
          .fetchEntries(refresh: true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Action failed'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}

// ─── Compact Mobile Card ───────────────────────────────────────────────────

class _MobileEntryCard extends StatelessWidget {
  const _MobileEntryCard({
    required this.entry,
    required this.role,
    required this.onTap,
    required this.onVerify,
    required this.onApprove,
    required this.onClose,
    required this.formatTimestamp,
    required this.vendorLabel,
  });

  final GateEntry entry;
  final UserRole? role;
  final VoidCallback onTap;
  final VoidCallback onVerify;
  final VoidCallback onApprove;
  final VoidCallback onClose;
  final String Function(DateTime?) formatTimestamp;
  final String Function(GateEntry) vendorLabel;

  bool get _isExited => entry.gateOutTimestamp != null;
  bool get _isGateIn => entry.gateMovement == GateMovement.inMovement;
  
  Color get _directionColor => (_isExited || !_isGateIn) ? Colors.deepOrange : Colors.indigo;
  IconData get _directionIcon => (_isExited || !_isGateIn) ? Icons.logout : Icons.login;
  String get _directionLabel => (_isExited || !_isGateIn) ? 'Gate Out' : 'Gate In';

  Color get _statusColor {
    switch (entry.status) {
      case 'inward_created':
        return Colors.orange;
      case 'verification_pending':
        return Colors.blue;
      case 'approved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.teal;
    }
  }

  String get _statusLabel {
    switch (entry.status) {
      case 'inward_created':
        return 'Pending';
      case 'verification_pending':
        return 'In Review';
      case 'approved':
        return 'Approved';
      case 'closed':
        return 'Closed';
      default:
        return entry.status;
    }
  }

  bool get _showVerify =>
      entry.status == 'inward_created' &&
      (role == UserRole.warehouseExecutive || role.isAdminOrWarehouseManager);
  bool get _showApprove =>
      entry.status == 'verification_pending' &&
      (role == UserRole.warehouseManager ||
          role == UserRole.admin ||
          role == UserRole.whMgr);
  bool get _showClose =>
      entry.status == 'approved' &&
      (role == UserRole.warehouseManager ||
          role == UserRole.admin ||
          role == UserRole.whMgr);
  bool get _showActions => _showVerify || _showApprove || _showClose;

  @override
  Widget build(BuildContext context) {
    final qty = entry.items.isNotEmpty
        ? entry.items.fold(0, (sum, i) => sum + i.challanQty)
        : 0;
    final materialCode =
        entry.items.isNotEmpty ? entry.items.first.materialCode : 'N/A';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _directionColor.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: direction icon + challan + status chip ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _directionColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_directionIcon, color: _directionColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.challanNo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _directionLabel,
                        style: TextStyle(
                          color: _directionColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ── Info row 1: Vendor + LR ──
            Row(
              children: [
                Expanded(
                  child: _infoCell(
                    context,
                    icon: Icons.store_outlined,
                    label: 'Vendor',
                    value: vendorLabel(entry),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _infoCell(
                    context,
                    icon: Icons.receipt_long_outlined,
                    label: 'LR No',
                    value: entry.lrNumber.isEmpty ? 'N/A' : entry.lrNumber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ── Info row 2: Vehicle + Qty ──
            Row(
              children: [
                Expanded(
                  child: _infoCell(
                    context,
                    icon: Icons.local_shipping_outlined,
                    label: 'Vehicle',
                    value: entry.vehicleNo.isEmpty ? 'N/A' : entry.vehicleNo,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _infoCell(
                    context,
                    icon: Icons.inventory_2_outlined,
                    label: 'Qty / Material',
                    value: '$qty  •  $materialCode',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ── Bottom row: time + optional driver ──
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    formatTimestamp(entry.gateTimestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (entry.driverContactNo.isNotEmpty) ...[
                  Icon(
                    Icons.phone_outlined,
                    size: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.driverContactNo,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            // ── Action buttons ──
            if (_showActions) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_showVerify)
                    _actionBtn(
                      context,
                      label: 'Verify',
                      color: Colors.blue,
                      onPressed: onVerify,
                    ),
                  if (_showApprove)
                    _actionBtn(
                      context,
                      label: 'Approve',
                      color: Colors.green,
                      onPressed: onApprove,
                    ),
                  if (_showClose)
                    _actionBtn(
                      context,
                      label: 'Close',
                      color: Colors.grey,
                      onPressed: onClose,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoCell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
    BuildContext context, {
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          minimumSize: const Size(0, 32),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}



// ---------------------------------------------------------------------------
// WAREHOUSE ENTRY VIEW (merged from warehouse_gate_entry_list_page.dart)
// ---------------------------------------------------------------------------

class _WarehouseGateEntryView extends ConsumerWidget {
  const _WarehouseGateEntryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(warehouseGateEntriesProvider);
    final session = ref.watch(sessionControllerProvider);
    final role = session is Authenticated ? session.role : null;
    final isManager =
        role == UserRole.warehouseManager || role == UserRole.whMgr;
    final isMob = isMobile(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isManager ? 'Gate Entries' : 'Pending GRNs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(warehouseGateEntriesProvider.future),
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: entries.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            SkeletonLoader(width: 260, height: 32),
            SizedBox(height: 16),
            SkeletonLoader(width: double.infinity, height: 120),
            SizedBox(height: 12),
            SkeletonLoader(width: double.infinity, height: 120),
          ],
        ),
        error: (e, _) => Center(child: Text('Failed to load entries: $e')),
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child:
                  Text(isManager ? 'No gate entries found' : 'No pending GRNs'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(warehouseGateEntriesProvider.future),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMob ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(
                    title: isManager
                        ? 'Warehouse Gate Entries'
                        : 'Gate Entries Pending GRN',
                    subtitle: isManager
                        ? 'Tap an entry to inspect details and approve or close it.'
                        : 'Tap an entry to inspect details and create GRN.',
                    trailing: isMob
                        ? null
                        : Text(
                            'Total: ${data.length}',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: isMob
                        ? _buildMobileList(data)
                        : _buildDesktopTable(context, data),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileList(List<WarehouseGateEntrySummary> entries) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GateEntryDetailPage(entryId: entry.id),
              ),
            );
          },
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          entry.gateEntryNo,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      StatusChip(
                        label: entry.statusLabel,
                        color: _statusColor(entry.statusLabel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Vendor: ${entry.vendorName}'),
                  const SizedBox(height: 6),
                  Text('Vehicle: ${entry.vehicleNo}'),
                  const SizedBox(height: 6),
                  Text(
                    'PO: ${entry.poNumber.isEmpty ? 'N/A' : entry.poNumber}',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Date: ${entry.entryTime != null ? DateFormat('MMM dd, yyyy • hh:mm a').format(entry.entryTime!) : 'N/A'}',
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
    BuildContext context,
    List<WarehouseGateEntrySummary> entries,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.5),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 24,
          minWidth: 800,
          columns: const [
            DataColumn2(label: Text('Gate Entry No'), size: ColumnSize.M),
            DataColumn2(label: Text('Vendor'), size: ColumnSize.L),
            DataColumn2(label: Text('Vehicle'), size: ColumnSize.M),
            DataColumn2(label: Text('Date'), size: ColumnSize.M),
            DataColumn2(label: Text('Status'), size: ColumnSize.S),
          ],
          rows: entries.map((entry) {
            return DataRow(
              onSelectChanged: (_) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        GateEntryDetailPage(entryId: entry.id),
                  ),
                );
              },
              cells: [
                DataCell(Text(entry.gateEntryNo)),
                DataCell(Text(entry.vendorName)),
                DataCell(Text(entry.vehicleNo)),
                DataCell(Text(
                  entry.entryTime != null
                      ? DateFormat('MMM dd, yyyy • hh:mm a')
                          .format(entry.entryTime!)
                      : 'N/A',
                )),
                DataCell(
                  StatusChip(
                    label: entry.statusLabel,
                    color: _statusColor(entry.statusLabel),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('closed')) return Colors.grey;
    if (normalized.contains('approved')) return Colors.green;
    if (normalized.contains('verified')) return Colors.blue;
    return Colors.orange;
  }
}
