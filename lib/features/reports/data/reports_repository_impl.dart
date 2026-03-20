import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/models/report_models.dart';
import '../domain/models/exception_report_item.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(apiClient: ref.read(apiClientProvider));
});

class ReportsRepository {
  final ApiClient _apiClient;

  ReportsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Map<String, dynamic> _buildQuery(ReportFilter filter) {
    final query = <String, dynamic>{};
    if (filter.startDate != null) {
      query['dateFrom'] = filter.startDate!.toIso8601String();
    }
    if (filter.endDate != null) {
      query['dateTo'] = filter.endDate!.toIso8601String();
    }
    if (filter.vendorFilter != null && filter.vendorFilter!.isNotEmpty) {
      query['vendor'] = filter.vendorFilter;
    }
    if (filter.poFilter != null && filter.poFilter!.isNotEmpty) {
      query['poNumber'] = filter.poFilter;
    }
    return query;
  }

  Future<List<GateEntryReportItem>> getGateEntryRegister(
      ReportFilter filter) async {
    final response = await _apiClient.getRaw(
      '/gate-entries',
      queryParameters: _buildQuery(filter),
    );

    final success = response['success'] as bool? ?? false;
    if (!success) return [];
    final data = response['data'];
    final list = data is List ? data : (response['items'] as List? ?? []);
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      final gateEntryNo = (map['gateEntryNo'] ?? map['gate_entry_no'] ?? '')
          .toString();
      final dateRaw =
          map['gateTimestamp'] ?? map['entryTime'] ?? map['createdAt'];
      final date = DateTime.tryParse(dateRaw?.toString() ?? '') ??
          DateTime.now();
      final vendor = (map['vendorName'] ?? map['vendor'] ?? '').toString();
      final poNumber =
          (map['poNumber'] ?? map['po_number'] ?? '').toString();
      final vehicleNo =
          (map['vehicleNo'] ?? map['vehicleNumber'] ?? '').toString();
      final material =
          (map['materialCode'] ?? map['material'] ?? '').toString();
      final status =
          (map['statusLabel'] ?? map['status'] ?? 'Pending').toString();

      return GateEntryReportItem(
        gateEntryNo: gateEntryNo,
        date: date,
        vendor: vendor,
        poNumber: poNumber,
        vehicleNo: vehicleNo,
        material: material,
        status: status,
      );
    }).toList();
  }

  Future<List<GrnReconReportItem>> getGrnReconReport(
      ReportFilter filter) async {
    final response = await _apiClient.getRaw(
      '/reconciliations',
      queryParameters: _buildQuery(filter),
    );

    final success = response['success'] as bool? ?? false;
    if (!success) return [];
    final data = response['data'];
    final list = data is List ? data : (response['items'] as List? ?? []);
    return list
        .map((e) => GrnReconReportItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ExceptionReportItem>> getExceptionReport(
      ReportFilter filter) async {
    final response = await _apiClient.getRaw(
      '/reconciliation/exceptions',
      queryParameters: _buildQuery(filter),
    );

    final success = response['success'] as bool? ?? false;
    if (!success) return [];
    final data = response['data'];
    final list = data is List ? data : (response['items'] as List? ?? []);
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return ExceptionReportItem(
        id: map['id']?.toString() ?? '',
        gateEntryId: map['gateEntryId']?.toString() ?? '',
        poNumber: map['poNumber']?.toString() ?? '',
        status: map['status']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }
}
