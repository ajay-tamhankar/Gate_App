import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/entities/reco_exception.dart';
import '../domain/entities/reconciliation_item.dart';
import '../domain/reco_repository.dart';

final recoRepositoryProvider = Provider<RecoRepository>((ref) {
  return RecoRepositoryImpl(apiClient: ref.read(apiClientProvider));
});

class RecoRepositoryImpl implements RecoRepository {
  final ApiClient _apiClient;

  RecoRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  @override
  Future<List<ReconciliationItem>> getReconciliations({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final query = <String, dynamic>{};
    if (dateFrom != null) {
      query['dateFrom'] = dateFrom.toIso8601String();
    }
    if (dateTo != null) {
      query['dateTo'] = dateTo.toIso8601String();
    }

    final response = await _apiClient.getRaw(
      '/reconciliations',
      queryParameters: query.isEmpty ? null : query,
    );

    final success = response['success'] as bool? ?? false;
    if (!success) {
      return [];
    }

    final data = response['data'];
    final list = data is List ? data : (response['items'] as List? ?? []);
    return list
        .map((e) => ReconciliationItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RecoException>> getExceptions() async {
    final response = await _apiClient.getRaw('/reconciliations');

    final success = response['success'] as bool? ?? false;
    if (!success) {
      return [];
    }

    final data = response['data'];
    final list = data is List ? data : (response['items'] as List? ?? []);

    return list
        .map((e) => RecoException.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RecoException> getExceptionDetail(String id) async {
    final response = await _apiClient.getRaw('/exceptions/$id');

    final success = response['success'] as bool? ?? false;
    if (!success || response['data'] == null) {
      throw Exception(
          response['message']?.toString() ?? 'Failed to load exception');
    }

    return RecoException.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> resolveException(String id, String resolutionNotes) async {
    final response = await _apiClient.postRaw(
      '/exceptions/$id/resolve',
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
}
