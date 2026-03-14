import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/mock_reports_repository.dart';
import '../domain/models/report_models.dart';
import '../domain/services/report_export_service.dart';

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
    'GRN Reconciliation',
    'Pending GRN',
    'Audit Trail'
  ];

  @override
  void dispose() {
    _vendorController.dispose();
    _poController.dispose();
    super.dispose();
  }

  void _exportExcel() async {
    final repo = ref.read(mockReportsRepositoryProvider);
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
      } else if (_selectedReport == 'GRN Reconciliation') {
        final data = await repo.getGrnReconReport(filter);
        await _exportService.exportGrnReconReportToExcel(data);
      } else if (_selectedReport == 'Pending GRN') {
        final data = await repo.getPendingGrnReport(filter);
        await _exportService.exportPendingGrnReportToExcel(data);
      } else if (_selectedReport == 'Audit Trail') {
        final data = await repo.getAuditTrailReport(filter);
        await _exportService.exportAuditTrailReportToExcel(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Excel Export Completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export Failed: $e')),
        );
      }
    }
  }

  void _exportPdf() async {
    final repo = ref.read(mockReportsRepositoryProvider);
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
      } else if (_selectedReport == 'GRN Reconciliation') {
        final data = await repo.getGrnReconReport(filter);
        await _exportService.exportGrnReconReportToPdf(data);
      } else if (_selectedReport == 'Pending GRN') {
        final data = await repo.getPendingGrnReport(filter);
        await _exportService.exportPendingGrnReportToPdf(data);
      } else if (_selectedReport == 'Audit Trail') {
        final data = await repo.getAuditTrailReport(filter);
        await _exportService.exportAuditTrailReportToPdf(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF Export Completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export Failed: $e')),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Widget _buildFilterBar() {
    final df = DateFormat('dd MMM yyyy');
    final dateText = _startDate != null && _endDate != null
        ? '${df.format(_startDate!)} - ${df.format(_endDate!)}'
        : 'Select Date Range';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButton<String>(
              value: _selectedReport,
              items: _reportTypes.map((t) {
                return DropdownMenuItem(value: t, child: Text(t));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedReport = val);
              },
            ),
            OutlinedButton.icon(
              onPressed: _selectDateRange,
              icon: const Icon(Icons.date_range),
              label: Text(dateText),
            ),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _vendorController,
                decoration: const InputDecoration(
                  labelText: 'Vendor Filter',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() {}),
              ),
            ),
            SizedBox(
              width: 150,
              child: TextField(
                controller: _poController,
                decoration: const InputDecoration(
                  labelText: 'PO Filter',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (v) => setState(() {}),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _exportExcel,
              icon: const Icon(Icons.table_chart),
              label: const Text('Export Excel'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
            ElevatedButton.icon(
              onPressed: _exportPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export PDF'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Exports')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilterBar(),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 2,
                child: Center(
                  child: Text(
                    'Preview of $_selectedReport will appear here.\nApply filters and use the Export buttons to generate the file.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
