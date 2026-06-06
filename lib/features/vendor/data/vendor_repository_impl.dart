import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/models/vendor.dart';
import '../domain/vendor_repository.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepositoryImpl(apiClient: ref.read(apiClientProvider));
});

class VendorRepositoryImpl implements VendorRepository {
  final ApiClient _apiClient;

  VendorRepositoryImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<VendorListResult> listVendors(VendorListQuery query) async {
    final params = <String, dynamic>{
      'limit': query.limit,
      'offset': query.offset,
    };
    final q = query.query?.trim();
    if (q != null && q.isNotEmpty) params['q'] = q;
    if (query.vendorType != null) {
      params['vendorType'] = query.vendorType!.apiValue;
    }
    if (query.isActive != null) params['isActive'] = query.isActive;

    final response = await _apiClient.getRaw(
      ApiEndpoints.vendorMaster,
      queryParameters: params,
    );

    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(
        response['message']?.toString() ?? 'Failed to load vendors',
      );
    }

    final data = response['data'];
    final list = data is List ? data : const [];
    final vendors = list
        .whereType<Map<String, dynamic>>()
        .map(Vendor.fromJson)
        .toList();

    final pagination = response['pagination'];
    int limit = query.limit;
    int offset = query.offset;
    int count = vendors.length;
    if (pagination is Map<String, dynamic>) {
      limit = _asInt(pagination['limit']) ?? limit;
      offset = _asInt(pagination['offset']) ?? offset;
      count = _asInt(pagination['count']) ?? count;
    }

    return VendorListResult(
      vendors: vendors,
      limit: limit,
      offset: offset,
      count: count,
    );
  }

  @override
  Future<Vendor> getVendor(String id) async {
    final response =
        await _apiClient.getRaw(ApiEndpoints.vendorMasterDetails(id));
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(
        response['message']?.toString() ?? 'Failed to load vendor',
      );
    }
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Vendor not found');
    }
    return Vendor.fromJson(data);
  }

  @override
  Future<Vendor> createVendor(VendorWriteRequest request) async {
    final response = await _apiClient.postRaw(
      ApiEndpoints.vendorMaster,
      data: request.toJson(),
    );
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(
        response['message']?.toString() ?? 'Failed to create vendor',
      );
    }
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Server returned no vendor data');
    }
    return Vendor.fromJson(data);
  }

  @override
  Future<Vendor> updateVendor(String id, VendorWriteRequest request) async {
    final response = await _apiClient.patchRaw(
      ApiEndpoints.vendorMasterDetails(id),
      data: request.toJson(),
    );
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(
        response['message']?.toString() ?? 'Failed to update vendor',
      );
    }
    final data = response['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Server returned no vendor data');
    }
    return Vendor.fromJson(data);
  }

  @override
  Future<void> deleteVendor(String id, {bool hard = false}) async {
    final response = await _apiClient.deleteRaw(
      ApiEndpoints.vendorMasterDetails(id),
      queryParameters: hard ? const {'hard': true} : null,
    );
    final success = response['success'] as bool? ?? false;
    if (!success) {
      throw Exception(
        response['message']?.toString() ?? 'Failed to delete vendor',
      );
    }
  }
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}
