import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/ui/responsive.dart';
import '../../../core/ui/widgets/status_chip.dart';
import '../../../core/ui/widgets/logout_action.dart';
import '../data/reports_repository_impl.dart';
import '../domain/models/report_models.dart';
import '../domain/models/exception_report_item.dart';
import '../domain/services/report_export_service.dart';

class _ReportQuery {
  final String reportType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? vendor;
  final String? po;

  const _ReportQuery({
    required this.reportType,
    required this.startDate,
    required this.endDate,
    required this.vendor,
    required this.po,
  });

  @override
  bool operator ==(Object other) {
    return other is _ReportQuery &&
        reportType == other.reportType &&
        _dtKey(startDate) == _dtKey(other.startDate) &&
        _dtKey(endDate) == _dtKey(other.endDate) &&
        vendor == other.vendor &&
        po == other.po;
  }

  @override
  int get hashCode => Object.hash(
        reportType,
        _dtKey(startDate),
        _dtKey(endDate),
        vendor,
        po,
      );

  String? _dtKey(DateTime? value) => value?.toIso8601String();
}

class _ReportPreviewData {
  final List<GateEntryReportItem> gateEntries;
  final List<GrnReconReportItem> grnRecons;
  final List<ExceptionReportItem> exceptions;

  const _ReportPreviewData({
    this.gateEntries = const [],
    this.grnRecons = const [],
    this.exceptions = const [],
  });
}

final reportsPreviewProvider =
    FutureProvider.autoDispose.family<_ReportPreviewData, _ReportQuery>(
  (ref, query) async {
    final repo = ref.read(reportsRepositoryProvider);
    final filter = ReportFilter(
      startDate: query.startDate,
      endDate: query.endDate,
      vendorFilter: query.vendor,
      poFilter: query.po,
    );

    if (query.reportType == 'Gate Entry Register') {
      final data = await repo.getGateEntryRegister(filter);
      return _ReportPreviewData(gateEntries: data);
    }
    if (query.reportType == 'GRN Reconciliation Report') {
      final data = await repo.getGrnReconReport(filter);
      return _ReportPreviewData(grnRecons: data);
    }
    final data = await repo.getExceptionReport(filter);
    return _ReportPreviewData(exceptions: data);
  },
);

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  final _exportService = ReportExportService();
  String _selectedReport = 'Gate Entry Register';

  // Filters
  DateTime? _startDate;
  DateTime? _endDate;
  final _vendorController = TextEditingController();
  final _poController = TextEditingController();

  final List<String> _reportTypes = [
    'Gate Entry Register',
    'GRN Reconciliation Report',
    'Exception Report',
  ];

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now().subtract(const Duration(days: 7));
    _endDate = DateTime.now();
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _poController.dispose();
    super.dispose();
  }

  void _exportExcel() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Export not supported on web yet.'),
              backgroundColor: Colors.orange),
        );
      }
      return;
    }
    final repo = ref.read(reportsRepositoryProvider);
    final filter = ReportFilter(
      startDate: _startDate,
      endDate: _endDate,
      vendorFilter:
          _vendorController.text.isNotEmpty ? _vendorController.text : null,
      poFilter: _poController.text.isNotEmpty ? _poController.text : null,
    );

    try {
      if (_selectedReport == 'Gate Entry Register') {
        final data = await repo.getGateEntryRegister(filter);
        await _exportService.exportGateEntryRegisterToExcel(data);
      } else if (_selectedReport == 'GRN Reconciliation Report') {
        final data = await repo.getGrnReconReport(filter);
        await _exportService.exportGrnReconReportToExcel(data);
      } else if (_selectedReport == 'Exception Report') {
        final data = await repo.getExceptionReport(filter);
        await _exportService.exportExceptionReportToExcel(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Excel Export Completed'),
              backgroundColor: Color(0xFF16A34A)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Export Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _exportPdf() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Export not supported on web yet.'),
              backgroundColor: Colors.orange),
        );
      }
      return;
    }
    final repo = ref.read(reportsRepositoryProvider);
    final filter = ReportFilter(
      startDate: _startDate,
      endDate: _endDate,
      vendorFilter:
          _vendorController.text.isNotEmpty ? _vendorController.text : null,
      poFilter: _poController.text.isNotEmpty ? _poController.text : null,
    );

    try {
      if (_selectedReport == 'Gate Entry Register') {
        final data = await repo.getGateEntryRegister(filter);
        await _exportService.exportGateEntryRegisterToPdf(data);
      } else if (_selectedReport == 'GRN Reconciliation Report') {
        final data = await repo.getGrnReconReport(filter);
        await _exportService.exportGrnReconReportToPdf(data);
      } else if (_selectedReport == 'Exception Report') {
        final data = await repo.getExceptionReport(filter);
        await _exportService.exportExceptionReportToPdf(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('PDF Export Completed'),
              backgroundColor: Color(0xFFDC2626)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Export Failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMob = isMobile(context);
    final df = DateFormat('MMM dd, yyyy');
    final dfShort = DateFormat('MMM dd');
    final dateText = _startDate != null && _endDate != null
        ? (isMob
            ? '${dfShort.format(_startDate!)} - ${dfShort.format(_endDate!)}'
            : '${df.format(_startDate!)} - ${df.format(_endDate!)}')
        : 'Select Date Range';
    final vendor = _vendorController.text.trim();
    final po = _poController.text.trim();
    final query = _ReportQuery(
      reportType: _selectedReport,
      startDate: _startDate,
      endDate: _endDate,
      vendor: vendor.isEmpty ? null : vendor,
      po: po.isEmpty ? null : po,
    );
    final previewAsync = ref.watch(reportsPreviewProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Exports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(reportsPreviewProvider(query)),
          ),
          const LogoutAction(),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMob ? 12.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text(
            //   'Reports & Exports',
            //   style: Theme.of(context)
            //       .textTheme
            //       .headlineSmall
            //       ?.copyWith(fontWeight: FontWeight.bold),
            // ),
            const SizedBox(height: 16),
            Card(
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmall = constraints.maxWidth < 600;

                    Widget item(Widget child) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: child,
                        ),
                      );
                    }

                    // 🔽 COMMON INPUT STYLE (compact)
                    InputDecoration inputStyle(String hint, IconData icon) {
                      return InputDecoration(
                        hintText: hint,
                        prefixIcon: Icon(icon, size: 18),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }

                    if (isSmall) {
                      // ✅ MOBILE → 2x2 layout
                      return Column(
                        children: [
                          Row(
                            children: [
                              item(
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedReport,
                                  isExpanded: true,
                                  decoration: inputStyle(
                                      'Report Type', Icons.analytics),
                                  items: _reportTypes.map((t) {
                                    return DropdownMenuItem(
                                      value: t,
                                      child: Text(t,
                                          style: const TextStyle(fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _selectedReport = val);
                                    }
                                  },
                                ),
                              ),
                              item(
                                OutlinedButton.icon(
                                  onPressed: _selectDateRange,
                                  icon: const Icon(Icons.date_range, size: 18),
                                  label: Text(
                                    dateText,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    alignment: Alignment.centerLeft,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              item(
                                TextField(
                                  controller: _vendorController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: inputStyle(
                                      'Vendor Filter', Icons.storefront),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              item(
                                TextField(
                                  controller: _poController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration:
                                      inputStyle('PO Filter', Icons.receipt),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              item(
                                FilledButton.icon(
                                  onPressed: _exportExcel,
                                  icon: const Icon(Icons.table_chart, size: 18),
                                  label: const Text('Excel',
                                      style: TextStyle(fontSize: 13)),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF16A34A),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                ),
                              ),
                              item(
                                FilledButton.icon(
                                  onPressed: _exportPdf,
                                  icon: const Icon(Icons.picture_as_pdf,
                                      size: 18),
                                  label: const Text('PDF',
                                      style: TextStyle(fontSize: 13)),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFDC2626),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // ✅ DESKTOP (UNCHANGED LOGIC)
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 220,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedReport,
                              isExpanded: true,
                              decoration:
                                  inputStyle('Report Type', Icons.analytics),
                              items: _reportTypes.map((t) {
                                return DropdownMenuItem(
                                    value: t,
                                    child: Text(t,
                                        style: const TextStyle(fontSize: 13)));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedReport = val);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 220,
                            child: OutlinedButton.icon(
                              onPressed: _selectDateRange,
                              icon: const Icon(Icons.date_range, size: 18),
                              label: Text(
                                dateText,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: TextField(
                              controller: _vendorController,
                              style: const TextStyle(fontSize: 13),
                              decoration:
                                  inputStyle('Vendor Filter', Icons.storefront),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          SizedBox(
                            width: 160,
                            child: TextField(
                              controller: _poController,
                              style: const TextStyle(fontSize: 13),
                              decoration:
                                  inputStyle('PO Filter', Icons.receipt),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: FilledButton.icon(
                              onPressed: _exportExcel,
                              icon: const Icon(Icons.table_chart, size: 18),
                              label: const Text('Export Excel',
                                  style: TextStyle(fontSize: 13)),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 140,
                            child: FilledButton.icon(
                              onPressed: _exportPdf,
                              icon: const Icon(Icons.picture_as_pdf, size: 18),
                              label: const Text('Export PDF',
                                  style: TextStyle(fontSize: 13)),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Showing results for $_selectedReport',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: isMob ? 420 : 520,
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: previewAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text(
                        'Failed to load data',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    data: (data) => _buildPreview(
                      context,
                      isMob,
                      data,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(
    BuildContext context,
    bool isMob,
    _ReportPreviewData data,
  ) {
    if (_selectedReport == 'Gate Entry Register') {
      if (data.gateEntries.isEmpty) {
        return _buildEmptyState(context);
      }
      return isMob
          ? _buildGateEntryMobile(context, data.gateEntries)
          : _buildGateEntryTable(context, data.gateEntries);
    }

    if (_selectedReport == 'GRN Reconciliation Report') {
      if (data.grnRecons.isEmpty) {
        return _buildEmptyState(context);
      }
      return isMob
          ? _buildGrnMobile(context, data.grnRecons)
          : _buildGrnTable(context, data.grnRecons);
    }

    if (data.exceptions.isEmpty) {
      return _buildEmptyState(context);
    }
    return isMob
        ? _buildExceptionMobile(context, data.exceptions)
        : _buildExceptionTable(context, data.exceptions);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'No records found',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _buildGateEntryTable(
      BuildContext context, List<GateEntryReportItem> items) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Gate Entry No')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Vendor')),
            DataColumn(label: Text('Vehicle No')),
            DataColumn(label: Text('PO No')),
            DataColumn(label: Text('Status')),
          ],
          rows: items
              .map(
                (e) => DataRow(cells: [
                  DataCell(Text(e.gateEntryNo)),
                  DataCell(Text(DateFormat('MMM dd, yyyy').format(e.date))),
                  DataCell(Text(e.vendor)),
                  DataCell(Text(e.vehicleNo)),
                  DataCell(Text(e.poNumber)),
                  DataCell(StatusChip(
                    label: e.status,
                    color: _statusColor(e.status),
                  )),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildGateEntryMobile(
      BuildContext context, List<GateEntryReportItem> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final e = items[index];
        return _previewCard(
          context,
          title: e.gateEntryNo,
          subtitle: '${e.vendor} • ${e.vehicleNo}',
          trailing: DateFormat('MMM dd').format(e.date),
          footer: StatusChip(label: e.status, color: _statusColor(e.status)),
        );
      },
    );
  }

  Widget _buildGrnTable(BuildContext context, List<GrnReconReportItem> items) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Gate Entry No')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Date')),
          ],
          rows: items
              .map(
                (e) => DataRow(cells: [
                  DataCell(Text(e.gateEntryNo)),
                  DataCell(StatusChip(
                    label: e.matchedStatus,
                    color: _statusColor(e.matchedStatus),
                  )),
                  const DataCell(Text('N/A')),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildGrnMobile(BuildContext context, List<GrnReconReportItem> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final e = items[index];
        return _previewCard(
          context,
          title: e.gateEntryNo,
          subtitle: e.matchedStatus,
          trailing: 'N/A',
          footer: StatusChip(
            label: e.matchedStatus,
            color: _statusColor(e.matchedStatus),
          ),
        );
      },
    );
  }

  Widget _buildExceptionTable(
      BuildContext context, List<ExceptionReportItem> items) {
    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Gate Entry No')),
            DataColumn(label: Text('Exception Type')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Date')),
          ],
          rows: items
              .map(
                (e) => DataRow(cells: [
                  DataCell(Text(e.gateEntryId)),
                  DataCell(Text(e.description)),
                  DataCell(StatusChip(
                    label: e.status,
                    color: _statusColor(e.status),
                  )),
                  DataCell(
                      Text(DateFormat('MMM dd, yyyy').format(e.createdAt))),
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildExceptionMobile(
      BuildContext context, List<ExceptionReportItem> items) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final e = items[index];
        return _previewCard(
          context,
          title: e.gateEntryId,
          subtitle: e.description,
          trailing: DateFormat('MMM dd').format(e.createdAt),
          footer: StatusChip(label: e.status, color: _statusColor(e.status)),
        );
      },
    );
  }

  Widget _previewCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String trailing,
    required Widget footer,
  }) {
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  trailing,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            footer,
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final key = status.toLowerCase();
    if (key.contains('match')) return Colors.green;
    if (key.contains('pending')) return Colors.orange;
    if (key.contains('exception') || key.contains('mismatch')) {
      return Colors.red;
    }
    return Colors.blueGrey;
  }
}
