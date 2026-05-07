// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'grn_import_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GrnImportResult _$GrnImportResultFromJson(Map<String, dynamic> json) {
  return _GrnImportResult.fromJson(json);
}

/// @nodoc
mixin _$GrnImportResult {
// Legacy fields for backward compatibility
  int? get processed => throw _privateConstructorUsedError;
  @JsonKey(name: 'totalRows')
  int? get totalRows => throw _privateConstructorUsedError;
  String? get adapterMode => throw _privateConstructorUsedError;
  ReconciliationSummary? get summary => throw _privateConstructorUsedError;
  List<BatchReconResult> get results =>
      throw _privateConstructorUsedError; // New fields from backend
  @JsonKey(name: 'importedCount')
  int? get importedCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'fileRowCount')
  int? get fileRowCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'validRowCount')
  int? get validRowCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'uniqueGrnCount')
  int? get uniqueGrnCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'upsertedRowCount')
  int? get upsertedRowCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'skippedCount')
  int? get skippedCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'skippedMessage')
  String? get skippedMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'skippedRows')
  List<Object?> get skippedRows => throw _privateConstructorUsedError;
  List<GrnImportRecord> get records => throw _privateConstructorUsedError;
  @JsonKey(name: 'reconciliation')
  GrnReconciliation? get reconciliation => throw _privateConstructorUsedError;

  /// Serializes this GrnImportResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrnImportResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrnImportResultCopyWith<GrnImportResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrnImportResultCopyWith<$Res> {
  factory $GrnImportResultCopyWith(
          GrnImportResult value, $Res Function(GrnImportResult) then) =
      _$GrnImportResultCopyWithImpl<$Res, GrnImportResult>;
  @useResult
  $Res call(
      {int? processed,
      @JsonKey(name: 'totalRows') int? totalRows,
      String? adapterMode,
      ReconciliationSummary? summary,
      List<BatchReconResult> results,
      @JsonKey(name: 'importedCount') int? importedCount,
      @JsonKey(name: 'fileRowCount') int? fileRowCount,
      @JsonKey(name: 'validRowCount') int? validRowCount,
      @JsonKey(name: 'uniqueGrnCount') int? uniqueGrnCount,
      @JsonKey(name: 'upsertedRowCount') int? upsertedRowCount,
      @JsonKey(name: 'skippedCount') int? skippedCount,
      @JsonKey(name: 'skippedMessage') String? skippedMessage,
      @JsonKey(name: 'skippedRows') List<Object?> skippedRows,
      List<GrnImportRecord> records,
      @JsonKey(name: 'reconciliation') GrnReconciliation? reconciliation});

  $ReconciliationSummaryCopyWith<$Res>? get summary;
  $GrnReconciliationCopyWith<$Res>? get reconciliation;
}

/// @nodoc
class _$GrnImportResultCopyWithImpl<$Res, $Val extends GrnImportResult>
    implements $GrnImportResultCopyWith<$Res> {
  _$GrnImportResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrnImportResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? processed = freezed,
    Object? totalRows = freezed,
    Object? adapterMode = freezed,
    Object? summary = freezed,
    Object? results = null,
    Object? importedCount = freezed,
    Object? fileRowCount = freezed,
    Object? validRowCount = freezed,
    Object? uniqueGrnCount = freezed,
    Object? upsertedRowCount = freezed,
    Object? skippedCount = freezed,
    Object? skippedMessage = freezed,
    Object? skippedRows = null,
    Object? records = null,
    Object? reconciliation = freezed,
  }) {
    return _then(_value.copyWith(
      processed: freezed == processed
          ? _value.processed
          : processed // ignore: cast_nullable_to_non_nullable
              as int?,
      totalRows: freezed == totalRows
          ? _value.totalRows
          : totalRows // ignore: cast_nullable_to_non_nullable
              as int?,
      adapterMode: freezed == adapterMode
          ? _value.adapterMode
          : adapterMode // ignore: cast_nullable_to_non_nullable
              as String?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as ReconciliationSummary?,
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<BatchReconResult>,
      importedCount: freezed == importedCount
          ? _value.importedCount
          : importedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      fileRowCount: freezed == fileRowCount
          ? _value.fileRowCount
          : fileRowCount // ignore: cast_nullable_to_non_nullable
              as int?,
      validRowCount: freezed == validRowCount
          ? _value.validRowCount
          : validRowCount // ignore: cast_nullable_to_non_nullable
              as int?,
      uniqueGrnCount: freezed == uniqueGrnCount
          ? _value.uniqueGrnCount
          : uniqueGrnCount // ignore: cast_nullable_to_non_nullable
              as int?,
      upsertedRowCount: freezed == upsertedRowCount
          ? _value.upsertedRowCount
          : upsertedRowCount // ignore: cast_nullable_to_non_nullable
              as int?,
      skippedCount: freezed == skippedCount
          ? _value.skippedCount
          : skippedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      skippedMessage: freezed == skippedMessage
          ? _value.skippedMessage
          : skippedMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      skippedRows: null == skippedRows
          ? _value.skippedRows
          : skippedRows // ignore: cast_nullable_to_non_nullable
              as List<Object?>,
      records: null == records
          ? _value.records
          : records // ignore: cast_nullable_to_non_nullable
              as List<GrnImportRecord>,
      reconciliation: freezed == reconciliation
          ? _value.reconciliation
          : reconciliation // ignore: cast_nullable_to_non_nullable
              as GrnReconciliation?,
    ) as $Val);
  }

  /// Create a copy of GrnImportResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReconciliationSummaryCopyWith<$Res>? get summary {
    if (_value.summary == null) {
      return null;
    }

    return $ReconciliationSummaryCopyWith<$Res>(_value.summary!, (value) {
      return _then(_value.copyWith(summary: value) as $Val);
    });
  }

  /// Create a copy of GrnImportResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GrnReconciliationCopyWith<$Res>? get reconciliation {
    if (_value.reconciliation == null) {
      return null;
    }

    return $GrnReconciliationCopyWith<$Res>(_value.reconciliation!, (value) {
      return _then(_value.copyWith(reconciliation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GrnImportResultImplCopyWith<$Res>
    implements $GrnImportResultCopyWith<$Res> {
  factory _$$GrnImportResultImplCopyWith(_$GrnImportResultImpl value,
          $Res Function(_$GrnImportResultImpl) then) =
      __$$GrnImportResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? processed,
      @JsonKey(name: 'totalRows') int? totalRows,
      String? adapterMode,
      ReconciliationSummary? summary,
      List<BatchReconResult> results,
      @JsonKey(name: 'importedCount') int? importedCount,
      @JsonKey(name: 'fileRowCount') int? fileRowCount,
      @JsonKey(name: 'validRowCount') int? validRowCount,
      @JsonKey(name: 'uniqueGrnCount') int? uniqueGrnCount,
      @JsonKey(name: 'upsertedRowCount') int? upsertedRowCount,
      @JsonKey(name: 'skippedCount') int? skippedCount,
      @JsonKey(name: 'skippedMessage') String? skippedMessage,
      @JsonKey(name: 'skippedRows') List<Object?> skippedRows,
      List<GrnImportRecord> records,
      @JsonKey(name: 'reconciliation') GrnReconciliation? reconciliation});

  @override
  $ReconciliationSummaryCopyWith<$Res>? get summary;
  @override
  $GrnReconciliationCopyWith<$Res>? get reconciliation;
}

/// @nodoc
class __$$GrnImportResultImplCopyWithImpl<$Res>
    extends _$GrnImportResultCopyWithImpl<$Res, _$GrnImportResultImpl>
    implements _$$GrnImportResultImplCopyWith<$Res> {
  __$$GrnImportResultImplCopyWithImpl(
      _$GrnImportResultImpl _value, $Res Function(_$GrnImportResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of GrnImportResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? processed = freezed,
    Object? totalRows = freezed,
    Object? adapterMode = freezed,
    Object? summary = freezed,
    Object? results = null,
    Object? importedCount = freezed,
    Object? fileRowCount = freezed,
    Object? validRowCount = freezed,
    Object? uniqueGrnCount = freezed,
    Object? upsertedRowCount = freezed,
    Object? skippedCount = freezed,
    Object? skippedMessage = freezed,
    Object? skippedRows = null,
    Object? records = null,
    Object? reconciliation = freezed,
  }) {
    return _then(_$GrnImportResultImpl(
      processed: freezed == processed
          ? _value.processed
          : processed // ignore: cast_nullable_to_non_nullable
              as int?,
      totalRows: freezed == totalRows
          ? _value.totalRows
          : totalRows // ignore: cast_nullable_to_non_nullable
              as int?,
      adapterMode: freezed == adapterMode
          ? _value.adapterMode
          : adapterMode // ignore: cast_nullable_to_non_nullable
              as String?,
      summary: freezed == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as ReconciliationSummary?,
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<BatchReconResult>,
      importedCount: freezed == importedCount
          ? _value.importedCount
          : importedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      fileRowCount: freezed == fileRowCount
          ? _value.fileRowCount
          : fileRowCount // ignore: cast_nullable_to_non_nullable
              as int?,
      validRowCount: freezed == validRowCount
          ? _value.validRowCount
          : validRowCount // ignore: cast_nullable_to_non_nullable
              as int?,
      uniqueGrnCount: freezed == uniqueGrnCount
          ? _value.uniqueGrnCount
          : uniqueGrnCount // ignore: cast_nullable_to_non_nullable
              as int?,
      upsertedRowCount: freezed == upsertedRowCount
          ? _value.upsertedRowCount
          : upsertedRowCount // ignore: cast_nullable_to_non_nullable
              as int?,
      skippedCount: freezed == skippedCount
          ? _value.skippedCount
          : skippedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      skippedMessage: freezed == skippedMessage
          ? _value.skippedMessage
          : skippedMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      skippedRows: null == skippedRows
          ? _value._skippedRows
          : skippedRows // ignore: cast_nullable_to_non_nullable
              as List<Object?>,
      records: null == records
          ? _value._records
          : records // ignore: cast_nullable_to_non_nullable
              as List<GrnImportRecord>,
      reconciliation: freezed == reconciliation
          ? _value.reconciliation
          : reconciliation // ignore: cast_nullable_to_non_nullable
              as GrnReconciliation?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrnImportResultImpl implements _GrnImportResult {
  const _$GrnImportResultImpl(
      {this.processed,
      @JsonKey(name: 'totalRows') this.totalRows,
      this.adapterMode,
      this.summary,
      final List<BatchReconResult> results = const [],
      @JsonKey(name: 'importedCount') this.importedCount,
      @JsonKey(name: 'fileRowCount') this.fileRowCount,
      @JsonKey(name: 'validRowCount') this.validRowCount,
      @JsonKey(name: 'uniqueGrnCount') this.uniqueGrnCount,
      @JsonKey(name: 'upsertedRowCount') this.upsertedRowCount,
      @JsonKey(name: 'skippedCount') this.skippedCount,
      @JsonKey(name: 'skippedMessage') this.skippedMessage,
      @JsonKey(name: 'skippedRows') final List<Object?> skippedRows = const [],
      final List<GrnImportRecord> records = const [],
      @JsonKey(name: 'reconciliation') this.reconciliation})
      : _results = results,
        _skippedRows = skippedRows,
        _records = records;

  factory _$GrnImportResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrnImportResultImplFromJson(json);

// Legacy fields for backward compatibility
  @override
  final int? processed;
  @override
  @JsonKey(name: 'totalRows')
  final int? totalRows;
  @override
  final String? adapterMode;
  @override
  final ReconciliationSummary? summary;
  final List<BatchReconResult> _results;
  @override
  @JsonKey()
  List<BatchReconResult> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

// New fields from backend
  @override
  @JsonKey(name: 'importedCount')
  final int? importedCount;
  @override
  @JsonKey(name: 'fileRowCount')
  final int? fileRowCount;
  @override
  @JsonKey(name: 'validRowCount')
  final int? validRowCount;
  @override
  @JsonKey(name: 'uniqueGrnCount')
  final int? uniqueGrnCount;
  @override
  @JsonKey(name: 'upsertedRowCount')
  final int? upsertedRowCount;
  @override
  @JsonKey(name: 'skippedCount')
  final int? skippedCount;
  @override
  @JsonKey(name: 'skippedMessage')
  final String? skippedMessage;
  final List<Object?> _skippedRows;
  @override
  @JsonKey(name: 'skippedRows')
  List<Object?> get skippedRows {
    if (_skippedRows is EqualUnmodifiableListView) return _skippedRows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_skippedRows);
  }

  final List<GrnImportRecord> _records;
  @override
  @JsonKey()
  List<GrnImportRecord> get records {
    if (_records is EqualUnmodifiableListView) return _records;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_records);
  }

  @override
  @JsonKey(name: 'reconciliation')
  final GrnReconciliation? reconciliation;

  @override
  String toString() {
    return 'GrnImportResult(processed: $processed, totalRows: $totalRows, adapterMode: $adapterMode, summary: $summary, results: $results, importedCount: $importedCount, fileRowCount: $fileRowCount, validRowCount: $validRowCount, uniqueGrnCount: $uniqueGrnCount, upsertedRowCount: $upsertedRowCount, skippedCount: $skippedCount, skippedMessage: $skippedMessage, skippedRows: $skippedRows, records: $records, reconciliation: $reconciliation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrnImportResultImpl &&
            (identical(other.processed, processed) ||
                other.processed == processed) &&
            (identical(other.totalRows, totalRows) ||
                other.totalRows == totalRows) &&
            (identical(other.adapterMode, adapterMode) ||
                other.adapterMode == adapterMode) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.importedCount, importedCount) ||
                other.importedCount == importedCount) &&
            (identical(other.fileRowCount, fileRowCount) ||
                other.fileRowCount == fileRowCount) &&
            (identical(other.validRowCount, validRowCount) ||
                other.validRowCount == validRowCount) &&
            (identical(other.uniqueGrnCount, uniqueGrnCount) ||
                other.uniqueGrnCount == uniqueGrnCount) &&
            (identical(other.upsertedRowCount, upsertedRowCount) ||
                other.upsertedRowCount == upsertedRowCount) &&
            (identical(other.skippedCount, skippedCount) ||
                other.skippedCount == skippedCount) &&
            (identical(other.skippedMessage, skippedMessage) ||
                other.skippedMessage == skippedMessage) &&
            const DeepCollectionEquality()
                .equals(other._skippedRows, _skippedRows) &&
            const DeepCollectionEquality().equals(other._records, _records) &&
            (identical(other.reconciliation, reconciliation) ||
                other.reconciliation == reconciliation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      processed,
      totalRows,
      adapterMode,
      summary,
      const DeepCollectionEquality().hash(_results),
      importedCount,
      fileRowCount,
      validRowCount,
      uniqueGrnCount,
      upsertedRowCount,
      skippedCount,
      skippedMessage,
      const DeepCollectionEquality().hash(_skippedRows),
      const DeepCollectionEquality().hash(_records),
      reconciliation);

  /// Create a copy of GrnImportResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrnImportResultImplCopyWith<_$GrnImportResultImpl> get copyWith =>
      __$$GrnImportResultImplCopyWithImpl<_$GrnImportResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GrnImportResultImplToJson(
      this,
    );
  }
}

abstract class _GrnImportResult implements GrnImportResult {
  const factory _GrnImportResult(
      {final int? processed,
      @JsonKey(name: 'totalRows') final int? totalRows,
      final String? adapterMode,
      final ReconciliationSummary? summary,
      final List<BatchReconResult> results,
      @JsonKey(name: 'importedCount') final int? importedCount,
      @JsonKey(name: 'fileRowCount') final int? fileRowCount,
      @JsonKey(name: 'validRowCount') final int? validRowCount,
      @JsonKey(name: 'uniqueGrnCount') final int? uniqueGrnCount,
      @JsonKey(name: 'upsertedRowCount') final int? upsertedRowCount,
      @JsonKey(name: 'skippedCount') final int? skippedCount,
      @JsonKey(name: 'skippedMessage') final String? skippedMessage,
      @JsonKey(name: 'skippedRows') final List<Object?> skippedRows,
      final List<GrnImportRecord> records,
      @JsonKey(name: 'reconciliation')
      final GrnReconciliation? reconciliation}) = _$GrnImportResultImpl;

  factory _GrnImportResult.fromJson(Map<String, dynamic> json) =
      _$GrnImportResultImpl.fromJson;

// Legacy fields for backward compatibility
  @override
  int? get processed;
  @override
  @JsonKey(name: 'totalRows')
  int? get totalRows;
  @override
  String? get adapterMode;
  @override
  ReconciliationSummary? get summary;
  @override
  List<BatchReconResult> get results; // New fields from backend
  @override
  @JsonKey(name: 'importedCount')
  int? get importedCount;
  @override
  @JsonKey(name: 'fileRowCount')
  int? get fileRowCount;
  @override
  @JsonKey(name: 'validRowCount')
  int? get validRowCount;
  @override
  @JsonKey(name: 'uniqueGrnCount')
  int? get uniqueGrnCount;
  @override
  @JsonKey(name: 'upsertedRowCount')
  int? get upsertedRowCount;
  @override
  @JsonKey(name: 'skippedCount')
  int? get skippedCount;
  @override
  @JsonKey(name: 'skippedMessage')
  String? get skippedMessage;
  @override
  @JsonKey(name: 'skippedRows')
  List<Object?> get skippedRows;
  @override
  List<GrnImportRecord> get records;
  @override
  @JsonKey(name: 'reconciliation')
  GrnReconciliation? get reconciliation;

  /// Create a copy of GrnImportResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrnImportResultImplCopyWith<_$GrnImportResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReconciliationSummary _$ReconciliationSummaryFromJson(
    Map<String, dynamic> json) {
  return _ReconciliationSummary.fromJson(json);
}

/// @nodoc
mixin _$ReconciliationSummary {
  ReconCounter get gateEntries => throw _privateConstructorUsedError;
  ReconCounter get lineItems => throw _privateConstructorUsedError;

  /// Serializes this ReconciliationSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReconciliationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReconciliationSummaryCopyWith<ReconciliationSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReconciliationSummaryCopyWith<$Res> {
  factory $ReconciliationSummaryCopyWith(ReconciliationSummary value,
          $Res Function(ReconciliationSummary) then) =
      _$ReconciliationSummaryCopyWithImpl<$Res, ReconciliationSummary>;
  @useResult
  $Res call({ReconCounter gateEntries, ReconCounter lineItems});

  $ReconCounterCopyWith<$Res> get gateEntries;
  $ReconCounterCopyWith<$Res> get lineItems;
}

/// @nodoc
class _$ReconciliationSummaryCopyWithImpl<$Res,
        $Val extends ReconciliationSummary>
    implements $ReconciliationSummaryCopyWith<$Res> {
  _$ReconciliationSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReconciliationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gateEntries = null,
    Object? lineItems = null,
  }) {
    return _then(_value.copyWith(
      gateEntries: null == gateEntries
          ? _value.gateEntries
          : gateEntries // ignore: cast_nullable_to_non_nullable
              as ReconCounter,
      lineItems: null == lineItems
          ? _value.lineItems
          : lineItems // ignore: cast_nullable_to_non_nullable
              as ReconCounter,
    ) as $Val);
  }

  /// Create a copy of ReconciliationSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReconCounterCopyWith<$Res> get gateEntries {
    return $ReconCounterCopyWith<$Res>(_value.gateEntries, (value) {
      return _then(_value.copyWith(gateEntries: value) as $Val);
    });
  }

  /// Create a copy of ReconciliationSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ReconCounterCopyWith<$Res> get lineItems {
    return $ReconCounterCopyWith<$Res>(_value.lineItems, (value) {
      return _then(_value.copyWith(lineItems: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ReconciliationSummaryImplCopyWith<$Res>
    implements $ReconciliationSummaryCopyWith<$Res> {
  factory _$$ReconciliationSummaryImplCopyWith(
          _$ReconciliationSummaryImpl value,
          $Res Function(_$ReconciliationSummaryImpl) then) =
      __$$ReconciliationSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ReconCounter gateEntries, ReconCounter lineItems});

  @override
  $ReconCounterCopyWith<$Res> get gateEntries;
  @override
  $ReconCounterCopyWith<$Res> get lineItems;
}

/// @nodoc
class __$$ReconciliationSummaryImplCopyWithImpl<$Res>
    extends _$ReconciliationSummaryCopyWithImpl<$Res,
        _$ReconciliationSummaryImpl>
    implements _$$ReconciliationSummaryImplCopyWith<$Res> {
  __$$ReconciliationSummaryImplCopyWithImpl(_$ReconciliationSummaryImpl _value,
      $Res Function(_$ReconciliationSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReconciliationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gateEntries = null,
    Object? lineItems = null,
  }) {
    return _then(_$ReconciliationSummaryImpl(
      gateEntries: null == gateEntries
          ? _value.gateEntries
          : gateEntries // ignore: cast_nullable_to_non_nullable
              as ReconCounter,
      lineItems: null == lineItems
          ? _value.lineItems
          : lineItems // ignore: cast_nullable_to_non_nullable
              as ReconCounter,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReconciliationSummaryImpl implements _ReconciliationSummary {
  const _$ReconciliationSummaryImpl(
      {required this.gateEntries, required this.lineItems});

  factory _$ReconciliationSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReconciliationSummaryImplFromJson(json);

  @override
  final ReconCounter gateEntries;
  @override
  final ReconCounter lineItems;

  @override
  String toString() {
    return 'ReconciliationSummary(gateEntries: $gateEntries, lineItems: $lineItems)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReconciliationSummaryImpl &&
            (identical(other.gateEntries, gateEntries) ||
                other.gateEntries == gateEntries) &&
            (identical(other.lineItems, lineItems) ||
                other.lineItems == lineItems));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gateEntries, lineItems);

  /// Create a copy of ReconciliationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReconciliationSummaryImplCopyWith<_$ReconciliationSummaryImpl>
      get copyWith => __$$ReconciliationSummaryImplCopyWithImpl<
          _$ReconciliationSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReconciliationSummaryImplToJson(
      this,
    );
  }
}

abstract class _ReconciliationSummary implements ReconciliationSummary {
  const factory _ReconciliationSummary(
      {required final ReconCounter gateEntries,
      required final ReconCounter lineItems}) = _$ReconciliationSummaryImpl;

  factory _ReconciliationSummary.fromJson(Map<String, dynamic> json) =
      _$ReconciliationSummaryImpl.fromJson;

  @override
  ReconCounter get gateEntries;
  @override
  ReconCounter get lineItems;

  /// Create a copy of ReconciliationSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReconciliationSummaryImplCopyWith<_$ReconciliationSummaryImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ReconCounter _$ReconCounterFromJson(Map<String, dynamic> json) {
  return _ReconCounter.fromJson(json);
}

/// @nodoc
mixin _$ReconCounter {
  int get total => throw _privateConstructorUsedError;
  int get matched => throw _privateConstructorUsedError;
  int get nonMatched => throw _privateConstructorUsedError;
  int get autoClosed => throw _privateConstructorUsedError;
  Map<String, int> get byStatus => throw _privateConstructorUsedError;

  /// Serializes this ReconCounter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReconCounter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReconCounterCopyWith<ReconCounter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReconCounterCopyWith<$Res> {
  factory $ReconCounterCopyWith(
          ReconCounter value, $Res Function(ReconCounter) then) =
      _$ReconCounterCopyWithImpl<$Res, ReconCounter>;
  @useResult
  $Res call(
      {int total,
      int matched,
      int nonMatched,
      int autoClosed,
      Map<String, int> byStatus});
}

/// @nodoc
class _$ReconCounterCopyWithImpl<$Res, $Val extends ReconCounter>
    implements $ReconCounterCopyWith<$Res> {
  _$ReconCounterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReconCounter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? matched = null,
    Object? nonMatched = null,
    Object? autoClosed = null,
    Object? byStatus = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      matched: null == matched
          ? _value.matched
          : matched // ignore: cast_nullable_to_non_nullable
              as int,
      nonMatched: null == nonMatched
          ? _value.nonMatched
          : nonMatched // ignore: cast_nullable_to_non_nullable
              as int,
      autoClosed: null == autoClosed
          ? _value.autoClosed
          : autoClosed // ignore: cast_nullable_to_non_nullable
              as int,
      byStatus: null == byStatus
          ? _value.byStatus
          : byStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReconCounterImplCopyWith<$Res>
    implements $ReconCounterCopyWith<$Res> {
  factory _$$ReconCounterImplCopyWith(
          _$ReconCounterImpl value, $Res Function(_$ReconCounterImpl) then) =
      __$$ReconCounterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int total,
      int matched,
      int nonMatched,
      int autoClosed,
      Map<String, int> byStatus});
}

/// @nodoc
class __$$ReconCounterImplCopyWithImpl<$Res>
    extends _$ReconCounterCopyWithImpl<$Res, _$ReconCounterImpl>
    implements _$$ReconCounterImplCopyWith<$Res> {
  __$$ReconCounterImplCopyWithImpl(
      _$ReconCounterImpl _value, $Res Function(_$ReconCounterImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReconCounter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? matched = null,
    Object? nonMatched = null,
    Object? autoClosed = null,
    Object? byStatus = null,
  }) {
    return _then(_$ReconCounterImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      matched: null == matched
          ? _value.matched
          : matched // ignore: cast_nullable_to_non_nullable
              as int,
      nonMatched: null == nonMatched
          ? _value.nonMatched
          : nonMatched // ignore: cast_nullable_to_non_nullable
              as int,
      autoClosed: null == autoClosed
          ? _value.autoClosed
          : autoClosed // ignore: cast_nullable_to_non_nullable
              as int,
      byStatus: null == byStatus
          ? _value._byStatus
          : byStatus // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReconCounterImpl implements _ReconCounter {
  const _$ReconCounterImpl(
      {required this.total,
      required this.matched,
      required this.nonMatched,
      this.autoClosed = 0,
      final Map<String, int> byStatus = const {}})
      : _byStatus = byStatus;

  factory _$ReconCounterImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReconCounterImplFromJson(json);

  @override
  final int total;
  @override
  final int matched;
  @override
  final int nonMatched;
  @override
  @JsonKey()
  final int autoClosed;
  final Map<String, int> _byStatus;
  @override
  @JsonKey()
  Map<String, int> get byStatus {
    if (_byStatus is EqualUnmodifiableMapView) return _byStatus;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_byStatus);
  }

  @override
  String toString() {
    return 'ReconCounter(total: $total, matched: $matched, nonMatched: $nonMatched, autoClosed: $autoClosed, byStatus: $byStatus)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReconCounterImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.matched, matched) || other.matched == matched) &&
            (identical(other.nonMatched, nonMatched) ||
                other.nonMatched == nonMatched) &&
            (identical(other.autoClosed, autoClosed) ||
                other.autoClosed == autoClosed) &&
            const DeepCollectionEquality().equals(other._byStatus, _byStatus));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, total, matched, nonMatched,
      autoClosed, const DeepCollectionEquality().hash(_byStatus));

  /// Create a copy of ReconCounter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReconCounterImplCopyWith<_$ReconCounterImpl> get copyWith =>
      __$$ReconCounterImplCopyWithImpl<_$ReconCounterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReconCounterImplToJson(
      this,
    );
  }
}

abstract class _ReconCounter implements ReconCounter {
  const factory _ReconCounter(
      {required final int total,
      required final int matched,
      required final int nonMatched,
      final int autoClosed,
      final Map<String, int> byStatus}) = _$ReconCounterImpl;

  factory _ReconCounter.fromJson(Map<String, dynamic> json) =
      _$ReconCounterImpl.fromJson;

  @override
  int get total;
  @override
  int get matched;
  @override
  int get nonMatched;
  @override
  int get autoClosed;
  @override
  Map<String, int> get byStatus;

  /// Create a copy of ReconCounter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReconCounterImplCopyWith<_$ReconCounterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BatchReconResult _$BatchReconResultFromJson(Map<String, dynamic> json) {
  return _BatchReconResult.fromJson(json);
}

/// @nodoc
mixin _$BatchReconResult {
  @JsonKey(name: 'gate_entry_id')
  String get gateEntryId => throw _privateConstructorUsedError;
  @JsonKey(name: 'gate_entry_no')
  String get gateEntryNo => throw _privateConstructorUsedError;
  @JsonKey(name: 'overallStatus')
  String get overallStatus => throw _privateConstructorUsedError;
  bool get autoClosed => throw _privateConstructorUsedError;
  double get qtyVariance => throw _privateConstructorUsedError;

  /// Serializes this BatchReconResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BatchReconResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BatchReconResultCopyWith<BatchReconResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchReconResultCopyWith<$Res> {
  factory $BatchReconResultCopyWith(
          BatchReconResult value, $Res Function(BatchReconResult) then) =
      _$BatchReconResultCopyWithImpl<$Res, BatchReconResult>;
  @useResult
  $Res call(
      {@JsonKey(name: 'gate_entry_id') String gateEntryId,
      @JsonKey(name: 'gate_entry_no') String gateEntryNo,
      @JsonKey(name: 'overallStatus') String overallStatus,
      bool autoClosed,
      double qtyVariance});
}

/// @nodoc
class _$BatchReconResultCopyWithImpl<$Res, $Val extends BatchReconResult>
    implements $BatchReconResultCopyWith<$Res> {
  _$BatchReconResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BatchReconResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gateEntryId = null,
    Object? gateEntryNo = null,
    Object? overallStatus = null,
    Object? autoClosed = null,
    Object? qtyVariance = null,
  }) {
    return _then(_value.copyWith(
      gateEntryId: null == gateEntryId
          ? _value.gateEntryId
          : gateEntryId // ignore: cast_nullable_to_non_nullable
              as String,
      gateEntryNo: null == gateEntryNo
          ? _value.gateEntryNo
          : gateEntryNo // ignore: cast_nullable_to_non_nullable
              as String,
      overallStatus: null == overallStatus
          ? _value.overallStatus
          : overallStatus // ignore: cast_nullable_to_non_nullable
              as String,
      autoClosed: null == autoClosed
          ? _value.autoClosed
          : autoClosed // ignore: cast_nullable_to_non_nullable
              as bool,
      qtyVariance: null == qtyVariance
          ? _value.qtyVariance
          : qtyVariance // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchReconResultImplCopyWith<$Res>
    implements $BatchReconResultCopyWith<$Res> {
  factory _$$BatchReconResultImplCopyWith(_$BatchReconResultImpl value,
          $Res Function(_$BatchReconResultImpl) then) =
      __$$BatchReconResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'gate_entry_id') String gateEntryId,
      @JsonKey(name: 'gate_entry_no') String gateEntryNo,
      @JsonKey(name: 'overallStatus') String overallStatus,
      bool autoClosed,
      double qtyVariance});
}

/// @nodoc
class __$$BatchReconResultImplCopyWithImpl<$Res>
    extends _$BatchReconResultCopyWithImpl<$Res, _$BatchReconResultImpl>
    implements _$$BatchReconResultImplCopyWith<$Res> {
  __$$BatchReconResultImplCopyWithImpl(_$BatchReconResultImpl _value,
      $Res Function(_$BatchReconResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of BatchReconResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gateEntryId = null,
    Object? gateEntryNo = null,
    Object? overallStatus = null,
    Object? autoClosed = null,
    Object? qtyVariance = null,
  }) {
    return _then(_$BatchReconResultImpl(
      gateEntryId: null == gateEntryId
          ? _value.gateEntryId
          : gateEntryId // ignore: cast_nullable_to_non_nullable
              as String,
      gateEntryNo: null == gateEntryNo
          ? _value.gateEntryNo
          : gateEntryNo // ignore: cast_nullable_to_non_nullable
              as String,
      overallStatus: null == overallStatus
          ? _value.overallStatus
          : overallStatus // ignore: cast_nullable_to_non_nullable
              as String,
      autoClosed: null == autoClosed
          ? _value.autoClosed
          : autoClosed // ignore: cast_nullable_to_non_nullable
              as bool,
      qtyVariance: null == qtyVariance
          ? _value.qtyVariance
          : qtyVariance // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchReconResultImpl implements _BatchReconResult {
  const _$BatchReconResultImpl(
      {@JsonKey(name: 'gate_entry_id') required this.gateEntryId,
      @JsonKey(name: 'gate_entry_no') required this.gateEntryNo,
      @JsonKey(name: 'overallStatus') required this.overallStatus,
      this.autoClosed = false,
      this.qtyVariance = 0.0});

  factory _$BatchReconResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchReconResultImplFromJson(json);

  @override
  @JsonKey(name: 'gate_entry_id')
  final String gateEntryId;
  @override
  @JsonKey(name: 'gate_entry_no')
  final String gateEntryNo;
  @override
  @JsonKey(name: 'overallStatus')
  final String overallStatus;
  @override
  @JsonKey()
  final bool autoClosed;
  @override
  @JsonKey()
  final double qtyVariance;

  @override
  String toString() {
    return 'BatchReconResult(gateEntryId: $gateEntryId, gateEntryNo: $gateEntryNo, overallStatus: $overallStatus, autoClosed: $autoClosed, qtyVariance: $qtyVariance)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchReconResultImpl &&
            (identical(other.gateEntryId, gateEntryId) ||
                other.gateEntryId == gateEntryId) &&
            (identical(other.gateEntryNo, gateEntryNo) ||
                other.gateEntryNo == gateEntryNo) &&
            (identical(other.overallStatus, overallStatus) ||
                other.overallStatus == overallStatus) &&
            (identical(other.autoClosed, autoClosed) ||
                other.autoClosed == autoClosed) &&
            (identical(other.qtyVariance, qtyVariance) ||
                other.qtyVariance == qtyVariance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gateEntryId, gateEntryNo,
      overallStatus, autoClosed, qtyVariance);

  /// Create a copy of BatchReconResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchReconResultImplCopyWith<_$BatchReconResultImpl> get copyWith =>
      __$$BatchReconResultImplCopyWithImpl<_$BatchReconResultImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchReconResultImplToJson(
      this,
    );
  }
}

abstract class _BatchReconResult implements BatchReconResult {
  const factory _BatchReconResult(
      {@JsonKey(name: 'gate_entry_id') required final String gateEntryId,
      @JsonKey(name: 'gate_entry_no') required final String gateEntryNo,
      @JsonKey(name: 'overallStatus') required final String overallStatus,
      final bool autoClosed,
      final double qtyVariance}) = _$BatchReconResultImpl;

  factory _BatchReconResult.fromJson(Map<String, dynamic> json) =
      _$BatchReconResultImpl.fromJson;

  @override
  @JsonKey(name: 'gate_entry_id')
  String get gateEntryId;
  @override
  @JsonKey(name: 'gate_entry_no')
  String get gateEntryNo;
  @override
  @JsonKey(name: 'overallStatus')
  String get overallStatus;
  @override
  bool get autoClosed;
  @override
  double get qtyVariance;

  /// Create a copy of BatchReconResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BatchReconResultImplCopyWith<_$BatchReconResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GrnImportRecord _$GrnImportRecordFromJson(Map<String, dynamic> json) {
  return _GrnImportRecord.fromJson(json);
}

/// @nodoc
mixin _$GrnImportRecord {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'grn_number')
  String get grnNumber => throw _privateConstructorUsedError;

  /// Serializes this GrnImportRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrnImportRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrnImportRecordCopyWith<GrnImportRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrnImportRecordCopyWith<$Res> {
  factory $GrnImportRecordCopyWith(
          GrnImportRecord value, $Res Function(GrnImportRecord) then) =
      _$GrnImportRecordCopyWithImpl<$Res, GrnImportRecord>;
  @useResult
  $Res call({String id, @JsonKey(name: 'grn_number') String grnNumber});
}

/// @nodoc
class _$GrnImportRecordCopyWithImpl<$Res, $Val extends GrnImportRecord>
    implements $GrnImportRecordCopyWith<$Res> {
  _$GrnImportRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrnImportRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? grnNumber = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      grnNumber: null == grnNumber
          ? _value.grnNumber
          : grnNumber // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GrnImportRecordImplCopyWith<$Res>
    implements $GrnImportRecordCopyWith<$Res> {
  factory _$$GrnImportRecordImplCopyWith(_$GrnImportRecordImpl value,
          $Res Function(_$GrnImportRecordImpl) then) =
      __$$GrnImportRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, @JsonKey(name: 'grn_number') String grnNumber});
}

/// @nodoc
class __$$GrnImportRecordImplCopyWithImpl<$Res>
    extends _$GrnImportRecordCopyWithImpl<$Res, _$GrnImportRecordImpl>
    implements _$$GrnImportRecordImplCopyWith<$Res> {
  __$$GrnImportRecordImplCopyWithImpl(
      _$GrnImportRecordImpl _value, $Res Function(_$GrnImportRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of GrnImportRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? grnNumber = null,
  }) {
    return _then(_$GrnImportRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      grnNumber: null == grnNumber
          ? _value.grnNumber
          : grnNumber // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrnImportRecordImpl implements _GrnImportRecord {
  const _$GrnImportRecordImpl(
      {required this.id, @JsonKey(name: 'grn_number') required this.grnNumber});

  factory _$GrnImportRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrnImportRecordImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'grn_number')
  final String grnNumber;

  @override
  String toString() {
    return 'GrnImportRecord(id: $id, grnNumber: $grnNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrnImportRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.grnNumber, grnNumber) ||
                other.grnNumber == grnNumber));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, grnNumber);

  /// Create a copy of GrnImportRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrnImportRecordImplCopyWith<_$GrnImportRecordImpl> get copyWith =>
      __$$GrnImportRecordImplCopyWithImpl<_$GrnImportRecordImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GrnImportRecordImplToJson(
      this,
    );
  }
}

abstract class _GrnImportRecord implements GrnImportRecord {
  const factory _GrnImportRecord(
          {required final String id,
          @JsonKey(name: 'grn_number') required final String grnNumber}) =
      _$GrnImportRecordImpl;

  factory _GrnImportRecord.fromJson(Map<String, dynamic> json) =
      _$GrnImportRecordImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'grn_number')
  String get grnNumber;

  /// Create a copy of GrnImportRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrnImportRecordImplCopyWith<_$GrnImportRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GrnReconciliation _$GrnReconciliationFromJson(Map<String, dynamic> json) {
  return _GrnReconciliation.fromJson(json);
}

/// @nodoc
mixin _$GrnReconciliation {
  @JsonKey(name: 'processed')
  int? get processed => throw _privateConstructorUsedError;
  @JsonKey(name: 'triggered')
  bool? get triggered => throw _privateConstructorUsedError;
  @JsonKey(name: 'success')
  bool? get success => throw _privateConstructorUsedError;
  @JsonKey(name: 'mode')
  String? get mode => throw _privateConstructorUsedError;
  @JsonKey(name: 'message')
  String? get message => throw _privateConstructorUsedError;

  /// Serializes this GrnReconciliation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrnReconciliation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrnReconciliationCopyWith<GrnReconciliation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrnReconciliationCopyWith<$Res> {
  factory $GrnReconciliationCopyWith(
          GrnReconciliation value, $Res Function(GrnReconciliation) then) =
      _$GrnReconciliationCopyWithImpl<$Res, GrnReconciliation>;
  @useResult
  $Res call(
      {@JsonKey(name: 'processed') int? processed,
      @JsonKey(name: 'triggered') bool? triggered,
      @JsonKey(name: 'success') bool? success,
      @JsonKey(name: 'mode') String? mode,
      @JsonKey(name: 'message') String? message});
}

/// @nodoc
class _$GrnReconciliationCopyWithImpl<$Res, $Val extends GrnReconciliation>
    implements $GrnReconciliationCopyWith<$Res> {
  _$GrnReconciliationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrnReconciliation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? processed = freezed,
    Object? triggered = freezed,
    Object? success = freezed,
    Object? mode = freezed,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      processed: freezed == processed
          ? _value.processed
          : processed // ignore: cast_nullable_to_non_nullable
              as int?,
      triggered: freezed == triggered
          ? _value.triggered
          : triggered // ignore: cast_nullable_to_non_nullable
              as bool?,
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      mode: freezed == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GrnReconciliationImplCopyWith<$Res>
    implements $GrnReconciliationCopyWith<$Res> {
  factory _$$GrnReconciliationImplCopyWith(_$GrnReconciliationImpl value,
          $Res Function(_$GrnReconciliationImpl) then) =
      __$$GrnReconciliationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'processed') int? processed,
      @JsonKey(name: 'triggered') bool? triggered,
      @JsonKey(name: 'success') bool? success,
      @JsonKey(name: 'mode') String? mode,
      @JsonKey(name: 'message') String? message});
}

/// @nodoc
class __$$GrnReconciliationImplCopyWithImpl<$Res>
    extends _$GrnReconciliationCopyWithImpl<$Res, _$GrnReconciliationImpl>
    implements _$$GrnReconciliationImplCopyWith<$Res> {
  __$$GrnReconciliationImplCopyWithImpl(_$GrnReconciliationImpl _value,
      $Res Function(_$GrnReconciliationImpl) _then)
      : super(_value, _then);

  /// Create a copy of GrnReconciliation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? processed = freezed,
    Object? triggered = freezed,
    Object? success = freezed,
    Object? mode = freezed,
    Object? message = freezed,
  }) {
    return _then(_$GrnReconciliationImpl(
      processed: freezed == processed
          ? _value.processed
          : processed // ignore: cast_nullable_to_non_nullable
              as int?,
      triggered: freezed == triggered
          ? _value.triggered
          : triggered // ignore: cast_nullable_to_non_nullable
              as bool?,
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      mode: freezed == mode
          ? _value.mode
          : mode // ignore: cast_nullable_to_non_nullable
              as String?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrnReconciliationImpl implements _GrnReconciliation {
  const _$GrnReconciliationImpl(
      {@JsonKey(name: 'processed') this.processed,
      @JsonKey(name: 'triggered') this.triggered,
      @JsonKey(name: 'success') this.success,
      @JsonKey(name: 'mode') this.mode,
      @JsonKey(name: 'message') this.message});

  factory _$GrnReconciliationImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrnReconciliationImplFromJson(json);

  @override
  @JsonKey(name: 'processed')
  final int? processed;
  @override
  @JsonKey(name: 'triggered')
  final bool? triggered;
  @override
  @JsonKey(name: 'success')
  final bool? success;
  @override
  @JsonKey(name: 'mode')
  final String? mode;
  @override
  @JsonKey(name: 'message')
  final String? message;

  @override
  String toString() {
    return 'GrnReconciliation(processed: $processed, triggered: $triggered, success: $success, mode: $mode, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrnReconciliationImpl &&
            (identical(other.processed, processed) ||
                other.processed == processed) &&
            (identical(other.triggered, triggered) ||
                other.triggered == triggered) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.mode, mode) || other.mode == mode) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, processed, triggered, success, mode, message);

  /// Create a copy of GrnReconciliation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrnReconciliationImplCopyWith<_$GrnReconciliationImpl> get copyWith =>
      __$$GrnReconciliationImplCopyWithImpl<_$GrnReconciliationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GrnReconciliationImplToJson(
      this,
    );
  }
}

abstract class _GrnReconciliation implements GrnReconciliation {
  const factory _GrnReconciliation(
          {@JsonKey(name: 'processed') final int? processed,
          @JsonKey(name: 'triggered') final bool? triggered,
          @JsonKey(name: 'success') final bool? success,
          @JsonKey(name: 'mode') final String? mode,
          @JsonKey(name: 'message') final String? message}) =
      _$GrnReconciliationImpl;

  factory _GrnReconciliation.fromJson(Map<String, dynamic> json) =
      _$GrnReconciliationImpl.fromJson;

  @override
  @JsonKey(name: 'processed')
  int? get processed;
  @override
  @JsonKey(name: 'triggered')
  bool? get triggered;
  @override
  @JsonKey(name: 'success')
  bool? get success;
  @override
  @JsonKey(name: 'mode')
  String? get mode;
  @override
  @JsonKey(name: 'message')
  String? get message;

  /// Create a copy of GrnReconciliation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrnReconciliationImplCopyWith<_$GrnReconciliationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
