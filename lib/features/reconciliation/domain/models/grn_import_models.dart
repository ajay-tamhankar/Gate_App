import 'package:freezed_annotation/freezed_annotation.dart';

part 'grn_import_models.freezed.dart';
part 'grn_import_models.g.dart';

@freezed
class GrnImportResult with _$GrnImportResult {
  const factory GrnImportResult({
    // Legacy fields for backward compatibility
    int? processed,
    @JsonKey(name: 'totalRows') int? totalRows,
    String? adapterMode,
    ReconciliationSummary? summary,
    @Default([]) List<BatchReconResult> results,
    // New fields from backend
    @JsonKey(name: 'importedCount') int? importedCount,
    @JsonKey(name: 'fileRowCount') int? fileRowCount,
    @JsonKey(name: 'validRowCount') int? validRowCount,
    @JsonKey(name: 'uniqueGrnCount') int? uniqueGrnCount,
    @JsonKey(name: 'upsertedRowCount') int? upsertedRowCount,
    @JsonKey(name: 'skippedCount') int? skippedCount,
    @JsonKey(name: 'skippedMessage') String? skippedMessage,
    @Default([]) @JsonKey(name: 'skippedRows') List<Object?> skippedRows,
    @Default([]) List<GrnImportRecord> records,
    @JsonKey(name: 'reconciliation') GrnReconciliation? reconciliation,
  }) = _GrnImportResult;

  factory GrnImportResult.fromJson(Map<String, dynamic> json) =>
      _$GrnImportResultFromJson(json);
}

@freezed
class ReconciliationSummary with _$ReconciliationSummary {
  const factory ReconciliationSummary({
    required ReconCounter gateEntries,
    required ReconCounter lineItems,
  }) = _ReconciliationSummary;

  factory ReconciliationSummary.fromJson(Map<String, dynamic> json) =>
      _$ReconciliationSummaryFromJson(json);
}

@freezed
class ReconCounter with _$ReconCounter {
  const factory ReconCounter({
    required int total,
    required int matched,
    required int nonMatched,
    @Default(0) int autoClosed,
    @Default({}) Map<String, int> byStatus,
  }) = _ReconCounter;

  factory ReconCounter.fromJson(Map<String, dynamic> json) =>
      _$ReconCounterFromJson(json);
}

@freezed
class BatchReconResult with _$BatchReconResult {
  const factory BatchReconResult({
    @JsonKey(name: 'gate_entry_id') required String gateEntryId,
    @JsonKey(name: 'gate_entry_no') required String gateEntryNo,
    @JsonKey(name: 'overallStatus') required String overallStatus,
    @Default(false) bool autoClosed,
    @Default(0.0) double qtyVariance,
  }) = _BatchReconResult;

  factory BatchReconResult.fromJson(Map<String, dynamic> json) =>
      _$BatchReconResultFromJson(json);
}

@freezed
class GrnImportRecord with _$GrnImportRecord {
  const factory GrnImportRecord({
    required String id,
    @JsonKey(name: 'grn_number') required String grnNumber,
  }) = _GrnImportRecord;

  factory GrnImportRecord.fromJson(Map<String, dynamic> json) =>
      _$GrnImportRecordFromJson(json);
}

@freezed
class GrnReconciliation with _$GrnReconciliation {
  const factory GrnReconciliation({
    @JsonKey(name: 'processed') int? processed,
    @JsonKey(name: 'triggered') bool? triggered,
    @JsonKey(name: 'success') bool? success,
    @JsonKey(name: 'mode') String? mode,
    @JsonKey(name: 'message') String? message,
  }) = _GrnReconciliation;

  factory GrnReconciliation.fromJson(Map<String, dynamic> json) =>
      _$GrnReconciliationFromJson(json);
}
