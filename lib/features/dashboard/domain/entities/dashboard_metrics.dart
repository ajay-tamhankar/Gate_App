import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_metrics.freezed.dart';
part 'dashboard_metrics.g.dart';

@freezed
class DashboardMetrics with _$DashboardMetrics {
  const factory DashboardMetrics({
    required int totalGateEntriesToday,
    required int totalGateEntriesMonth,
    required int totalGrnPosted,
    required int pendingGrnCount,
    required int quantityMismatchCases,
    required int duplicateGrnCases,
    required int pendingGrnAging0To1,
    required int pendingGrnAging2To3,
    required int pendingGrnAgingMoreThan3,
    required double gateTat,
    required double dockTat,
    required int pendingReconciliations,
    required int matchedDraws,
    required int exceptionsRaised,
    required List<DailyActivity> recentActivity,
  }) = _DashboardMetrics;

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) =>
      _$DashboardMetricsFromJson(json);
}

@freezed
class DailyActivity with _$DailyActivity {
  const factory DailyActivity({
    required String day,
    required int entriesCount,
  }) = _DailyActivity;

  factory DailyActivity.fromJson(Map<String, dynamic> json) =>
      _$DailyActivityFromJson(json);
}
