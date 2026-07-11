import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/entities/reco_exception.dart';
import '../domain/entities/reconciliation_item.dart';
import '../domain/reconciliation_period_filter.dart';
import '../domain/reco_repository.dart';

final recoRepositoryProvider = Provider<RecoRepository>((ref) {
  return RecoRepositoryImpl(apiClient: ref.read(apiClientProvider));
});

class RecoRepositoryImpl implements RecoRepository {
  final ApiClient _apiClient;

  RecoRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  // Hard client-side cap so a misbehaving server or huge backlog can never
  // pull the entire history of reconciliations into the app.
  static const int _maxRecords = 500;

  @override
  Future<List<ReconciliationItem>> getReconciliations({
    DateTime? dateFrom,
    DateTime? dateTo,
    ReconciliationPeriodFilter? filter,
  }) async {
    final query = <String, dynamic>{'limit': _maxRecords};
    final hasExplicitRange = dateFrom != null || dateTo != null;
    if (dateFrom != null) {
      query['dateFrom'] = dateFrom.toIso8601String();
    }
    if (dateTo != null) {
      query['dateTo'] = dateTo.toIso8601String();
    }
    if (!hasExplicitRange &&
        filter != null &&
        filter != ReconciliationPeriodFilter.all) {
      query['filter'] = filter.apiValue;
    }

    final response = await _apiClient.getRaw(
      '/reconciliations',
      queryParameters: query,
    );

    final success = response['success'] as bool? ?? false;
    if (!success) {
      return const [];
    }

    final data = response['data'];
    final list = data is List ? data : (response['items'] as List? ?? []);
    return list
        .map((e) => ReconciliationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RecoException>> getExceptions() async {
    final response = await _apiClient.getRaw(
      '/reconciliation/exceptions',
      queryParameters: const {'limit': _maxRecords},
    );

    final success = response['success'] as bool? ?? false;
    if (!success) {
      return [];
    }

    final data = response['data'];
    final list = data is List ? data : (response['items'] as List? ?? []);

    return list.map((e) => _mapRecoException(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<RecoException> getExceptionDetail(String id) async {
    try {
      final response = await _apiClient.getRaw('/reconciliation/exceptions/$id');
      final success = response['success'] as bool? ?? false;
      final data = response['data'];
      if (success && data is Map<String, dynamic>) {
        return _mapRecoException(data);
      }
    } catch (_) {
      // Fallback for backends that expose only list endpoint.
    }

    final items = await getExceptions();
    for (final item in items) {
      if (item.id == id) return item;
    }
    throw Exception('Failed to load exception details');
  }

  @override
  Future<void> resolveException(String id, String resolutionNotes) async {
    final response = await _apiClient.postRaw(
      '/reconciliation/exceptions/$id/resolve',
      data: {'resolutionNotes': resolutionNotes},
    );

    final success = response['success'] as bool? ?? false;
    if (!success) {
      final message = response['message']?.toString() ?? 'Resolve failed';
      final error = response['error'];
      if (error is Map<String, dynamic> && error['message'] != null) {
        throw Exception(error['message'].toString());
      }
      throw Exception(message);
    }
  }

  void clearForTest() {}

  RecoException _mapRecoException(Map<String, dynamic> json) {
    num readNum(dynamic value) {
      if (value is num) return value;
      if (value == null) return 0;
      return num.tryParse(value.toString()) ?? 0;
    }

    String humanize(String value) {
      if (value.trim().isEmpty) return 'Unknown';
      return value
          .split('_')
          .where((part) => part.isNotEmpty)
          .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
          .join(' ');
    }

    final id = (json['id'] ??
            json['_id'] ??
            json['reconciliationId'] ??
            json['recoId'] ??
            '')
        .toString();

    final gateEntryNo = (json['gateEntryNo'] ??
            json['gate_entry_no'] ??
            json['gateEntryId'] ??
            json['gate_entry_id'] ??
            '')
        .toString();

    final rawStatus = (json['status'] ?? '').toString();
    final status = (json['statusLabel'] ?? '').toString().trim().isNotEmpty
        ? (json['statusLabel'] ?? '').toString()
        : humanize(rawStatus);

    final matchedGrnNumber = (json['matchedGrnNumber'] ?? '').toString();
    final qtyVariance = readNum(json['qtyVariance']);
    final baseReason = (json['displayReason'] ?? json['reasonCode'] ?? '-').toString();
    final description = qtyVariance == 0
        ? baseReason
        : '$baseReason (Qty variance: $qtyVariance)';

    final createdAtRaw = (json['createdAt'] ??
            json['reconciledAt'] ??
            json['created_at'] ??
            '')
        .toString();

    final createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();

    return RecoException(
      id: id,
      gateEntryId: gateEntryNo,
      poNumber: matchedGrnNumber.isNotEmpty ? matchedGrnNumber : '-',
      status: status,
      description: description,
      createdAt: createdAt,
      resolvedAt: json['resolvedAt']?.toString(),
      resolvedBy: json['resolvedBy']?.toString(),
    );
  }
}
