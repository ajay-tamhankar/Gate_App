import 'package:freezed_annotation/freezed_annotation.dart';

part 'grn_import_models.freezed.dart';
part 'grn_import_models.g.dart';

@freezed
class GrnImportResult with _$GrnImportResult {
  const factory GrnImportResult({
    int? processed,
    @JsonKey(name: 'importedCount') int? importedCount,
    @JsonKey(name: 'totalRows') int? totalRows,
    @JsonKey(name: 'skippedCount') int? skippedCount,
    String? adapterMode,
    ReconciliationSummary? summary,
    @Default([]) List<BatchReconResult> results,
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
