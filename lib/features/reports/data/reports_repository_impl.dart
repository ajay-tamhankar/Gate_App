import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/pagination_model.dart';
import '../../../core/network/dio_provider.dart';
import '../../gate_entry/domain/models/gate_entry_summary.dart';
import '../domain/models/report_models.dart';
import '../domain/models/exception_report_item.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  return ReportsRepository(apiClient: ref.read(apiClientProvider));
});

/// Tolerate qty fields the backend may return as num, decimal string
/// ("432.0000"), or null. Bare `as num` casts crash on the string form —
/// see warehouse_gate_entry.dart for the matching fix on the detail path.
num _readNum(dynamic value) {
  if (value is num) return value;
  if (value == null) return 0;
  return num.tryParse(value.toString()) ?? 0;
}

class ReportsRepository {
  final ApiClient _apiClient;

  ReportsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Map<String, dynamic> _buildQuery(
    ReportFilter filter, {
    bool includeLimit = true,
    int? page,
    int? limit,
    String? q,
    String? period,
    String? sortBy,
    String? sortOrder,
    String? status,
    String? challan,
    String? vendor,
    String? po,
  }) {
    final query = <String, dynamic>{};
    if (includeLimit) {
      query['limit'] = limit ?? 100000;
    } else if (limit != null) {
      query['limit'] = limit;
    }
    if (page != null) {
      query['page'] = page;
    }
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
    final hasExplicitRange =
        query.containsKey('dateFrom') || query.containsKey('dateTo');
    if (q != null && q.isNotEmpty) {
      query['q'] = q;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      query['sortBy'] = sortBy;
    }
    if (sortOrder != null && sortOrder.isNotEmpty) {
      query['sortOrder'] = sortOrder;
    }
    if (status != null && status.isNotEmpty) {
      query['status'] = status;
    }
    if (challan != null && challan.isNotEmpty) {
      query['challan'] = challan;
    }
    if (vendor != null && vendor.isNotEmpty) {
      query['vendor'] = vendor;
    }
    if (po != null && po.isNotEmpty) {
      query['po'] = po;
    }
    if (!hasExplicitRange && period != null && period.isNotEmpty) {
      query['period'] = period;
    }
    return query;
  }

  List<dynamic> _extractList(dynamic response, {String key = 'data'}) {
    final root = response is Map<String, dynamic> ? response : const <String, dynamic>{};
    final data = root[key];

    if (data is List) return data;

    if (data is Map<String, dynamic>) {
      final candidates = [
        data['items'],
        data['records'],
        data['rows'],
        data['results'],
      ];
      for (final candidate in candidates) {
        if (candidate is List) return candidate;
      }
    }

    final topCandidates = [
      root['items'],
      root['records'],
      root['rows'],
      root['results'],
    ];
    for (final candidate in topCandidates) {
      if (candidate is List) return candidate;
    }

    return const [];
  }

  Future<List<GateEntryReportItem>> getGateEntryRegister(
    ReportFilter filter, {
    String? q,
    String? period,
    String? sortBy,
    String? sortOrder,
    String? status,
    String? challan,
    String? vendor,
    String? po,
  }) async {
    final response = await _apiClient.getRaw(
      '/gate-entries',
      queryParameters: _buildQuery(
        filter,
        includeLimit: false,
        q: q,
        period: period,
        sortBy: sortBy,
        sortOrder: sortOrder,
        status: status,
        challan: challan,
        vendor: vendor,
        po: po,
      ),
    );

    final success = response['success'] as bool? ?? false;
    if (!success) return [];
    final list = _extractList(response);
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      final items = map['items'];
      final itemList = items is List ? items : const [];
      final gateEntryNo = (map['gateEntryNo'] ?? map['gate_entry_no'] ?? '')
          .toString();
      final directionRaw =
          (map['gateMovement'] ?? map['gate_movement'] ?? '').toString();
      final challanNo =
          (map['challanNo'] ?? map['challan_no'] ?? map['invoiceNo'] ?? '')
              .toString();
      final lrNo = (map['lrNumber'] ?? map['lr_number'] ?? '').toString();
      final dateRaw =
          map['gateTimestamp'] ?? map['entryTime'] ?? map['createdAt'];
      final date = DateTime.tryParse(dateRaw?.toString() ?? '') ??
          DateTime.now();
      final gateOutRaw = map['gateOutTimestamp'] ??
          map['gate_out_timestamp'] ??
          map['gateOutTime'];
      final gateOutDate = DateTime.tryParse(gateOutRaw?.toString() ?? '');
      final isExited = gateOutDate != null;
      final direction = isExited ||
              directionRaw == 'out' ||
              directionRaw == 'outMovement'
          ? 'Gate Out'
          : 'Gate In';
      final vendor = (map['vendorName'] ?? map['vendor'] ?? '').toString();
      final vendorCode =
          (map['vendorCode'] ?? map['vendor_code'] ?? '').toString();
      final poNumber =
          (map['poNumber'] ?? map['po_number'] ?? '').toString();
      final vehicleNo =
          (map['vehicleNo'] ?? map['vehicleNumber'] ?? '').toString();
      final material = itemList.isNotEmpty
          ? ((itemList.first as Map<String, dynamic>)['materialCode'] ??
                  (itemList.first as Map<String, dynamic>)['material'] ??
                  '')
              .toString()
          : (map['materialCode'] ?? map['material'] ?? '').toString();
      final qty = itemList.isNotEmpty
          ? itemList.fold<int>(0, (sum, item) {
              final itemMap = item as Map<String, dynamic>;
              return sum +
                  _readNum(itemMap['challanQty'] ?? itemMap['challan_qty'])
                      .toInt();
            })
          : _readNum(map['qty'] ?? map['quantity']).toInt();
      final transporter =
          (map['transporterName'] ?? map['transporter'] ?? '').toString();
      final status =
          (map['statusLabel'] ?? map['status'] ?? 'Pending').toString();

      return GateEntryReportItem(
        gateEntryNo: gateEntryNo,
        direction: direction,
        challanNo: challanNo,
        lrNo: lrNo,
        date: date,
        gateOutDate: gateOutDate,
        material: material,
        qty: qty,
        vendor: vendor,
        vendorCode: vendorCode,
        transporter: transporter,
        vehicleNo: vehicleNo,
        poNumber: poNumber,
        status: status,
      );
    }).toList();
  }

  Future<GateEntryReportPage> getGateEntryRegisterPage(
    ReportFilter filter, {
    String? q,
    String? period,
    String? sortBy,
    String? sortOrder,
    String? status,
    String? challan,
    String? vendor,
    String? po,
    int? page,
    int? limit,
  }) async {
    final response = await _apiClient.getRaw(
      '/gate-entries',
      queryParameters: _buildQuery(
        filter,
        includeLimit: false,
        page: page,
        limit: limit == null ? null : (limit > 100 ? 100 : limit),
        q: q,
        period: period,
        sortBy: sortBy,
        sortOrder: sortOrder,
        status: status,
        challan: challan,
        vendor: vendor,
        po: po,
      ),
    );

    final success = response['success'] as bool? ?? false;
    if (!success) return const GateEntryReportPage();
    final list = _extractList(response);
    final items = list.map((e) {
      final map = e as Map<String, dynamic>;
      final items = map['items'];
      final itemList = items is List ? items : const [];
      final gateEntryNo = (map['gateEntryNo'] ?? map['gate_entry_no'] ?? '')
          .toString();
      final directionRaw =
          (map['gateMovement'] ?? map['gate_movement'] ?? '').toString();
      final challanNo =
          (map['challanNo'] ?? map['challan_no'] ?? map['invoiceNo'] ?? '')
              .toString();
      final lrNo = (map['lrNumber'] ?? map['lr_number'] ?? '').toString();
      final dateRaw =
          map['gateTimestamp'] ?? map['entryTime'] ?? map['createdAt'];
      final date = DateTime.tryParse(dateRaw?.toString() ?? '') ??
          DateTime.now();
      final gateOutRaw = map['gateOutTimestamp'] ??
          map['gate_out_timestamp'] ??
          map['gateOutTime'];
      final gateOutDate = DateTime.tryParse(gateOutRaw?.toString() ?? '');
      final isExited = gateOutDate != null;
      final direction = isExited ||
              directionRaw == 'out' ||
              directionRaw == 'outMovement'
          ? 'Gate Out'
          : 'Gate In';
      final vendor = (map['vendorName'] ?? map['vendor'] ?? '').toString();
      final vendorCode =
          (map['vendorCode'] ?? map['vendor_code'] ?? '').toString();
      final poNumber =
          (map['poNumber'] ?? map['po_number'] ?? '').toString();
      final vehicleNo =
          (map['vehicleNo'] ?? map['vehicleNumber'] ?? '').toString();
      final material = itemList.isNotEmpty
          ? ((itemList.first as Map<String, dynamic>)['materialCode'] ??
                  (itemList.first as Map<String, dynamic>)['material'] ??
                  '')
              .toString()
          : (map['materialCode'] ?? map['material'] ?? '').toString();
      final qty = itemList.isNotEmpty
          ? itemList.fold<int>(0, (sum, item) {
              final itemMap = item as Map<String, dynamic>;
              return sum +
                  _readNum(itemMap['challanQty'] ?? itemMap['challan_qty'])
                      .toInt();
            })
          : _readNum(map['qty'] ?? map['quantity']).toInt();
      final transporter =
          (map['transporterName'] ?? map['transporter'] ?? '').toString();
      final status =
          (map['statusLabel'] ?? map['status'] ?? 'Pending').toString();

      return GateEntryReportItem(
        gateEntryNo: gateEntryNo,
        direction: direction,
        challanNo: challanNo,
        lrNo: lrNo,
        date: date,
        gateOutDate: gateOutDate,
        material: material,
        qty: qty,
        vendor: vendor,
        vendorCode: vendorCode,
        transporter: transporter,
        vehicleNo: vehicleNo,
        poNumber: poNumber,
        status: status,
      );
    }).toList();

    final summaryJson = response['summary'] as Map<String, dynamic>?;
    final paginationJson = response['pagination'] as Map<String, dynamic>?;

    return GateEntryReportPage(
      items: items,
      summary: summaryJson == null
          ? const GateEntrySummary()
          : GateEntrySummary.fromJson(summaryJson),
      pagination: paginationJson == null
          ? null
          : PaginationModel.fromJson(paginationJson),
    );
  }

  Future<List<GrnReconReportItem>> getGrnReconReport(
      ReportFilter filter) async {
    final response = await _apiClient.getRaw(
      '/reconciliations',
      queryParameters: _buildQuery(filter),
    );

    final success = response['success'] as bool? ?? false;
    if (!success) return [];
    final list = _extractList(response);
    return list
        .whereType<Map<String, dynamic>>()
        .map((json) {
          try {
            return GrnReconReportItem.fromJson(json);
          } catch (_) {
            // Keep reports resilient even when one record has inconsistent typing.
            return GrnReconReportItem.fromJson({
              'gateEntryNo': (json['gateEntryNo'] ?? json['gate_entry_no'] ?? '').toString(),
              'grnNo': (json['grnNo'] ?? json['matchedGrnNumber'] ?? json['materialDocument'] ?? '').toString(),
              'poNumber': (json['poNumber'] ?? json['po_number'] ?? json['purchaseOrder'] ?? '').toString(),
              'challanNo': (json['challanNo'] ?? json['challan_no'] ?? json['referenceNo'] ?? '').toString(),
              'matchedStatus': (json['matchedStatus'] ?? json['statusLabel'] ?? json['status'] ?? '').toString(),
              'quantityDiff': json['quantityDiff'] ?? json['quantity_diff'] ?? json['qtyVariance'] ?? 0,
              'vendorName': (json['vendorName'] ?? json['vendor_name'] ?? json['vendor'] ?? '').toString(),
              'reconciledAt': (json['reconciledAt'] ?? json['createdAt'] ?? json['date'] ?? '').toString(),
              'remarks': (json['remarks'] ?? json['displayReason'] ?? '').toString(),
              'status': (json['status'] ?? json['statusLabel'] ?? '').toString(),
              'mdr': (json['mdr'] ?? json['reasonCode'] ?? '').toString(),
              'userName': (json['userName'] ?? json['reconciledBy'] ?? '').toString(),
            });
          }
        })
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
    final list = _extractList(response);
    return list.map((e) {
      final map = e as Map<String, dynamic>;
      return ExceptionReportItem(
        id: map['id']?.toString() ?? '',
        gateEntryId: map['gateEntryId']?.toString() ?? '',
        poNumber: (map['matchedGrnNumber'] ?? '').toString(),
        status: (map['statusLabel'] ?? map['status'] ?? '').toString(),
        description: (map['displayReason'] ?? map['reasonCode'] ?? '').toString(),
        createdAt: DateTime.tryParse(
                (map['reconciledAt'] ?? map['createdAt'])?.toString() ?? '') ??
            DateTime.now(),
      );
    }).toList();
  }
}
