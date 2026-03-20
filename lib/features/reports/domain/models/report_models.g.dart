// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReportFilterImpl _$$ReportFilterImplFromJson(Map<String, dynamic> json) =>
    _$ReportFilterImpl(
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      vendorFilter: json['vendorFilter'] as String?,
      poFilter: json['poFilter'] as String?,
    );

Map<String, dynamic> _$$ReportFilterImplToJson(_$ReportFilterImpl instance) =>
    <String, dynamic>{
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'vendorFilter': instance.vendorFilter,
      'poFilter': instance.poFilter,
    };

_$GateEntryReportItemImpl _$$GateEntryReportItemImplFromJson(
        Map<String, dynamic> json) =>
    _$GateEntryReportItemImpl(
      gateEntryNo: json['gateEntryNo'] as String,
      date: DateTime.parse(json['date'] as String),
      vendor: json['vendor'] as String,
      poNumber: json['poNumber'] as String,
      vehicleNo: json['vehicleNo'] as String,
      material: json['material'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$$GateEntryReportItemImplToJson(
        _$GateEntryReportItemImpl instance) =>
    <String, dynamic>{
      'gateEntryNo': instance.gateEntryNo,
      'date': instance.date.toIso8601String(),
      'vendor': instance.vendor,
      'poNumber': instance.poNumber,
      'vehicleNo': instance.vehicleNo,
      'material': instance.material,
      'status': instance.status,
    };

_$GrnReconReportItemImpl _$$GrnReconReportItemImplFromJson(
        Map<String, dynamic> json) =>
    _$GrnReconReportItemImpl(
      gateEntryNo: json['gateEntryNo'] as String,
      grnNo: json['grnNo'] as String,
      poNumber: json['poNumber'] as String,
      challanNo: json['challanNo'] as String,
      matchedStatus: json['matchedStatus'] as String,
      quantityDiff: (json['quantityDiff'] as num).toDouble(),
    );

Map<String, dynamic> _$$GrnReconReportItemImplToJson(
        _$GrnReconReportItemImpl instance) =>
    <String, dynamic>{
      'gateEntryNo': instance.gateEntryNo,
      'grnNo': instance.grnNo,
      'poNumber': instance.poNumber,
      'challanNo': instance.challanNo,
      'matchedStatus': instance.matchedStatus,
      'quantityDiff': instance.quantityDiff,
    };

_$PendingGrnReportItemImpl _$$PendingGrnReportItemImplFromJson(
        Map<String, dynamic> json) =>
    _$PendingGrnReportItemImpl(
      gateEntryNo: json['gateEntryNo'] as String,
      poNumber: json['poNumber'] as String,
      vendor: json['vendor'] as String,
      material: json['material'] as String,
      daysPending: (json['daysPending'] as num).toInt(),
    );

Map<String, dynamic> _$$PendingGrnReportItemImplToJson(
        _$PendingGrnReportItemImpl instance) =>
    <String, dynamic>{
      'gateEntryNo': instance.gateEntryNo,
      'poNumber': instance.poNumber,
      'vendor': instance.vendor,
      'material': instance.material,
      'daysPending': instance.daysPending,
    };

_$AuditTrailReportItemImpl _$$AuditTrailReportItemImplFromJson(
        Map<String, dynamic> json) =>
    _$AuditTrailReportItemImpl(
      date: DateTime.parse(json['date'] as String),
      user: json['user'] as String,
      action: json['action'] as String,
      entity: json['entity'] as String,
      changes: json['changes'] as String,
    );

Map<String, dynamic> _$$AuditTrailReportItemImplToJson(
        _$AuditTrailReportItemImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'user': instance.user,
      'action': instance.action,
      'entity': instance.entity,
      'changes': instance.changes,
    };
