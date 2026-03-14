// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_metrics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardMetricsImpl _$$DashboardMetricsImplFromJson(
        Map<String, dynamic> json) =>
    _$DashboardMetricsImpl(
      totalGateEntriesToday: (json['totalGateEntriesToday'] as num).toInt(),
      totalGateEntriesMonth: (json['totalGateEntriesMonth'] as num).toInt(),
      totalGrnPosted: (json['totalGrnPosted'] as num).toInt(),
      pendingGrnCount: (json['pendingGrnCount'] as num).toInt(),
      quantityMismatchCases: (json['quantityMismatchCases'] as num).toInt(),
      duplicateGrnCases: (json['duplicateGrnCases'] as num).toInt(),
      pendingGrnAging0To1: (json['pendingGrnAging0To1'] as num).toInt(),
      pendingGrnAging2To3: (json['pendingGrnAging2To3'] as num).toInt(),
      pendingGrnAgingMoreThan3:
          (json['pendingGrnAgingMoreThan3'] as num).toInt(),
      gateTat: (json['gateTat'] as num).toDouble(),
      dockTat: (json['dockTat'] as num).toDouble(),
      pendingReconciliations: (json['pendingReconciliations'] as num).toInt(),
      matchedDraws: (json['matchedDraws'] as num).toInt(),
      exceptionsRaised: (json['exceptionsRaised'] as num).toInt(),
      recentActivity: (json['recentActivity'] as List<dynamic>)
          .map((e) => DailyActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$DashboardMetricsImplToJson(
        _$DashboardMetricsImpl instance) =>
    <String, dynamic>{
      'totalGateEntriesToday': instance.totalGateEntriesToday,
      'totalGateEntriesMonth': instance.totalGateEntriesMonth,
      'totalGrnPosted': instance.totalGrnPosted,
      'pendingGrnCount': instance.pendingGrnCount,
      'quantityMismatchCases': instance.quantityMismatchCases,
      'duplicateGrnCases': instance.duplicateGrnCases,
      'pendingGrnAging0To1': instance.pendingGrnAging0To1,
      'pendingGrnAging2To3': instance.pendingGrnAging2To3,
      'pendingGrnAgingMoreThan3': instance.pendingGrnAgingMoreThan3,
      'gateTat': instance.gateTat,
      'dockTat': instance.dockTat,
      'pendingReconciliations': instance.pendingReconciliations,
      'matchedDraws': instance.matchedDraws,
      'exceptionsRaised': instance.exceptionsRaised,
      'recentActivity': instance.recentActivity,
    };

_$DailyActivityImpl _$$DailyActivityImplFromJson(Map<String, dynamic> json) =>
    _$DailyActivityImpl(
      day: json['day'] as String,
      entriesCount: (json['entriesCount'] as num).toInt(),
    );

Map<String, dynamic> _$$DailyActivityImplToJson(_$DailyActivityImpl instance) =>
    <String, dynamic>{
      'day': instance.day,
      'entriesCount': instance.entriesCount,
    };
