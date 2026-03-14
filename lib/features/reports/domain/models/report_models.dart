import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_models.freezed.dart';
part 'report_models.g.dart';

@freezed
class ReportFilter with _$ReportFilter {
  const factory ReportFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? vendorFilter,
    String? poFilter,
  }) = _ReportFilter;

  factory ReportFilter.fromJson(Map<String, dynamic> json) =>
      _$ReportFilterFromJson(json);
}

@freezed
class GateEntryReportItem with _$GateEntryReportItem {
  const factory GateEntryReportItem({
    required String gateEntryNo,
    required DateTime date,
    required String vendor,
    required String poNumber,
    required String vehicleNo,
    required String material,
    required String status,
  }) = _GateEntryReportItem;

  factory GateEntryReportItem.fromJson(Map<String, dynamic> json) =>
      _$GateEntryReportItemFromJson(json);
}

@freezed
class GrnReconReportItem with _$GrnReconReportItem {
  const factory GrnReconReportItem({
    required String gateEntryNo,
    required String grnNo,
    required String poNumber,
    required String challanNo,
    required String matchedStatus,
    required double quantityDiff,
  }) = _GrnReconReportItem;

  factory GrnReconReportItem.fromJson(Map<String, dynamic> json) =>
      _$GrnReconReportItemFromJson(json);
}

@freezed
class PendingGrnReportItem with _$PendingGrnReportItem {
  const factory PendingGrnReportItem({
    required String gateEntryNo,
    required String poNumber,
    required String vendor,
    required String material,
    required int daysPending,
  }) = _PendingGrnReportItem;

  factory PendingGrnReportItem.fromJson(Map<String, dynamic> json) =>
      _$PendingGrnReportItemFromJson(json);
}

@freezed
class AuditTrailReportItem with _$AuditTrailReportItem {
  const factory AuditTrailReportItem({
    required DateTime date,
    required String user,
    required String action,
    required String entity,
    required String changes,
  }) = _AuditTrailReportItem;

  factory AuditTrailReportItem.fromJson(Map<String, dynamic> json) =>
      _$AuditTrailReportItemFromJson(json);
}
