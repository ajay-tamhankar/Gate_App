import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/models/warehouse_gate_entry.dart';
import '../domain/models/warehouse_grn.dart';
import '../domain/models/warehouse_reconciliation.dart';
import '../domain/warehouse_repository.dart';
import '../../reconciliation/domain/reconciliation_period_filter.dart';

final warehouseRepositoryProvider = Provider<WarehouseRepository>((ref) {
  return WarehouseRepositoryImpl(apiClient: ref.read(apiClientProvider));
});

class WarehouseRepositoryImpl implements WarehouseRepository {
  final ApiClient _apiClient;

  WarehouseRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  // Hard client-side cap so the warehouse screens never pull the entire
  // history into the app. The screens already cap rendering at ~200 rows.
  static const int _maxRecords = 500;

  @override
  Future<List<WarehouseGateEntrySummary>> getGateEntries() async {
    final response = await _apiClient.getRaw(
      '/gate-entries',
      queryParameters: const {'limit': _maxRecords},
    );
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Failed to load gate entries');
    }

    final data = response['data'];
    final list = data is List ? data : const [];
    final entries = list
        .whereType<Map<String, dynamic>>()
        .map(WarehouseGateEntrySummary.fromJson)
        .where((e) => !e.isCompleted)
        .toList();
    return entries;
  }

  @override
  Future<WarehouseGateEntryDetail> getGateEntryDetail(String id) async {
    final response = await _apiClient.getRaw('/gate-entries/$id');
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Failed to load gate entry');
    }
    final data = response['data'] as Map<String, dynamic>? ?? const {};
    return WarehouseGateEntryDetail.fromJson(data);
  }

  @override
  Future<WarehouseGateEntryDetail> verifyGateEntry(
    String id,
    WarehouseGateEntryVerificationRequest request,
  ) async {
    final response = await _apiClient.postRaw(
      '/gate-entries/$id/verify',
      data: request.toJson(),
    );
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Failed to verify gate entry');
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return WarehouseGateEntryDetail.fromJson(data);
    }

    return getGateEntryDetail(id);
  }

  @override
  Future<void> approveGateEntry(String id) async {
    final response = await _apiClient.postRaw('/gate-entries/$id/approve');
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Failed to approve gate entry');
    }
  }

  @override
  Future<void> closeGateEntry(String id) async {
    final response = await _apiClient.postRaw('/gate-entries/$id/close');
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Failed to close gate entry');
    }
  }

  @override
  Future<String?> getAttachmentUrl(String id, String attachmentId) async {
    final response = await _apiClient.getRaw(
      '/gate-entries/$id/attachments/$attachmentId/url',
    );
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Failed to fetch attachment URL');
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return (data['url'] ?? data['signedUrl'])?.toString();
    }
    if (data is String) return data;
    return response['url']?.toString();
  }

  @override
  Future<void> createGrn(WarehouseGrnRequest request) async {
    final response = await _apiClient.postRaw('/grn', data: request.toJson());
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Failed to create GRN');
    }
  }

  @override
  Future<List<WarehouseReconciliationRecord>> getReconciliations({
    DateTime? dateFrom,
    DateTime? dateTo,
    ReconciliationPeriodFilter? filter,
  }) async {
    final params = <String, dynamic>{'limit': _maxRecords};
    final hasExplicitRange = dateFrom != null || dateTo != null;
    if (dateFrom != null) {
      params['dateFrom'] = dateFrom.toIso8601String();
    }
    if (dateTo != null) {
      params['dateTo'] = dateTo.toIso8601String();
    }
    if (!hasExplicitRange && filter != null) {
      params['filter'] = filter.apiValue;
    }

    final response = await _apiClient.getRaw(
      '/reconciliations',
      queryParameters: params,
    );
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Failed to load reconciliations');
    }

    final data = response['data'];
    final list = data is List ? data : const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(WarehouseReconciliationRecord.fromJson)
        .toList();
  }

  @override
  Future<void> approveReconciliation(
    String id,
    WarehouseReconciliationActionRequest request,
  ) async {
    final response = await _apiClient.postRaw(
      '/reconciliations/$id/approve',
      data: request.toJson(),
    );
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Failed to approve reconciliation');
    }
  }

  @override
  Future<void> closeReconciliation(
    String id,
    WarehouseReconciliationActionRequest request,
  ) async {
    final response = await _apiClient.postRaw(
      '/reconciliations/$id/close',
      data: request.toJson(),
    );
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(response['message'] ?? 'Failed to close reconciliation');
    }
  }
}




