// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grn_import_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GrnImportResultImpl _$$GrnImportResultImplFromJson(
        Map<String, dynamic> json) =>
    _$GrnImportResultImpl(
      processed: (json['processed'] as num?)?.toInt(),
      importedCount: (json['importedCount'] as num?)?.toInt(),
      adapterMode: json['adapterMode'] as String?,
      summary: json['summary'] == null
          ? null
          : ReconciliationSummary.fromJson(
              json['summary'] as Map<String, dynamic>),
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => BatchReconResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GrnImportResultImplToJson(
        _$GrnImportResultImpl instance) =>
    <String, dynamic>{
      'processed': instance.processed,
      'importedCount': instance.importedCount,
      'adapterMode': instance.adapterMode,
      'summary': instance.summary,
      'results': instance.results,
    };

_$ReconciliationSummaryImpl _$$ReconciliationSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$ReconciliationSummaryImpl(
      gateEntries:
          ReconCounter.fromJson(json['gateEntries'] as Map<String, dynamic>),
      lineItems:
          ReconCounter.fromJson(json['lineItems'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ReconciliationSummaryImplToJson(
        _$ReconciliationSummaryImpl instance) =>
    <String, dynamic>{
      'gateEntries': instance.gateEntries,
      'lineItems': instance.lineItems,
    };

_$ReconCounterImpl _$$ReconCounterImplFromJson(Map<String, dynamic> json) =>
    _$ReconCounterImpl(
      total: (json['total'] as num).toInt(),
      matched: (json['matched'] as num).toInt(),
      nonMatched: (json['nonMatched'] as num).toInt(),
      autoClosed: (json['autoClosed'] as num?)?.toInt() ?? 0,
      byStatus: (json['byStatus'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
    );

Map<String, dynamic> _$$ReconCounterImplToJson(_$ReconCounterImpl instance) =>
    <String, dynamic>{
      'total': instance.total,
      'matched': instance.matched,
      'nonMatched': instance.nonMatched,
      'autoClosed': instance.autoClosed,
      'byStatus': instance.byStatus,
    };

_$BatchReconResultImpl _$$BatchReconResultImplFromJson(
        Map<String, dynamic> json) =>
    _$BatchReconResultImpl(
      gateEntryId: json['gate_entry_id'] as String,
      gateEntryNo: json['gate_entry_no'] as String,
      overallStatus: json['overallStatus'] as String,
      autoClosed: json['autoClosed'] as bool? ?? false,
      qtyVariance: (json['qtyVariance'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$BatchReconResultImplToJson(
        _$BatchReconResultImpl instance) =>
    <String, dynamic>{
      'gate_entry_id': instance.gateEntryId,
      'gate_entry_no': instance.gateEntryNo,
      'overallStatus': instance.overallStatus,
      'autoClosed': instance.autoClosed,
      'qtyVariance': instance.qtyVariance,
    };
