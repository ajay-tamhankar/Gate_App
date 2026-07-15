import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../../../core/network/dio_provider.dart';
import '../domain/entities/dashboard_metrics.dart';

final dashboardApiProvider = Provider<DashboardApi>((ref) {
  return DashboardApi(apiClient: ref.read(apiClientProvider));
});

class DashboardApi {
  final ApiClient _apiClient;

  DashboardApi({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<DashboardMetrics>> fetchMetrics() async {
    return _apiClient.get<DashboardMetrics>(
      ApiEndpoints.dashboardSecurity,
      fromJsonT: (json) =>
          DashboardMetrics.fromJson(json as Map<String, dynamic>),
    );
  }
}
