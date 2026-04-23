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
  int? get processed => throw _privateConstructorUsedError;
  @JsonKey(name: 'importedCount')
  int? get importedCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'totalRows')
  int? get totalRows => throw _privateConstructorUsedError;
  @JsonKey(name: 'skippedCount')
  int? get skippedCount => throw _privateConstructorUsedError;
  String? get adapterMode => throw _privateConstructorUsedError;
  ReconciliationSummary? get summary => throw _privateConstructorUsedError;
  List<BatchReconResult> get results => throw _privateConstructorUsedError;

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
      @JsonKey(name: 'importedCount') int? importedCount,
      @JsonKey(name: 'totalRows') int? totalRows,
      @JsonKey(name: 'skippedCount') int? skippedCount,
      String? adapterMode,
      ReconciliationSummary? summary,
      List<BatchReconResult> results});

  $ReconciliationSummaryCopyWith<$Res>? get summary;
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
    Object? importedCount = freezed,
    Object? totalRows = freezed,
    Object? skippedCount = freezed,
    Object? adapterMode = freezed,
    Object? summary = freezed,
    Object? results = null,
  }) {
    return _then(_value.copyWith(
      processed: freezed == processed
          ? _value.processed
          : processed // ignore: cast_nullable_to_non_nullable
              as int?,
      importedCount: freezed == importedCount
          ? _value.importedCount
          : importedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      totalRows: freezed == totalRows
          ? _value.totalRows
          : totalRows // ignore: cast_nullable_to_non_nullable
              as int?,
      skippedCount: freezed == skippedCount
          ? _value.skippedCount
          : skippedCount // ignore: cast_nullable_to_non_nullable
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
      @JsonKey(name: 'importedCount') int? importedCount,
      @JsonKey(name: 'totalRows') int? totalRows,
      @JsonKey(name: 'skippedCount') int? skippedCount,
      String? adapterMode,
      ReconciliationSummary? summary,
      List<BatchReconResult> results});

  @override
  $ReconciliationSummaryCopyWith<$Res>? get summary;
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
    Object? importedCount = freezed,
    Object? totalRows = freezed,
    Object? skippedCount = freezed,
    Object? adapterMode = freezed,
    Object? summary = freezed,
    Object? results = null,
  }) {
    return _then(_$GrnImportResultImpl(
      processed: freezed == processed
          ? _value.processed
          : processed // ignore: cast_nullable_to_non_nullable
              as int?,
      importedCount: freezed == importedCount
          ? _value.importedCount
          : importedCount // ignore: cast_nullable_to_non_nullable
              as int?,
      totalRows: freezed == totalRows
          ? _value.totalRows
          : totalRows // ignore: cast_nullable_to_non_nullable
              as int?,
      skippedCount: freezed == skippedCount
          ? _value.skippedCount
          : skippedCount // ignore: cast_nullable_to_non_nullable
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrnImportResultImpl implements _GrnImportResult {
  const _$GrnImportResultImpl(
      {this.processed,
      @JsonKey(name: 'importedCount') this.importedCount,
      @JsonKey(name: 'totalRows') this.totalRows,
      @JsonKey(name: 'skippedCount') this.skippedCount,
      this.adapterMode,
      this.summary,
      final List<BatchReconResult> results = const []})
      : _results = results;

  factory _$GrnImportResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrnImportResultImplFromJson(json);

  @override
  final int? processed;
  @override
  @JsonKey(name: 'importedCount')
  final int? importedCount;
  @override
  @JsonKey(name: 'totalRows')
  final int? totalRows;
  @override
  @JsonKey(name: 'skippedCount')
  final int? skippedCount;
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

  @override
  String toString() {
    return 'GrnImportResult(processed: $processed, importedCount: $importedCount, totalRows: $totalRows, skippedCount: $skippedCount, adapterMode: $adapterMode, summary: $summary, results: $results)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrnImportResultImpl &&
            (identical(other.processed, processed) ||
                other.processed == processed) &&
            (identical(other.importedCount, importedCount) ||
                other.importedCount == importedCount) &&
            (identical(other.totalRows, totalRows) ||
                other.totalRows == totalRows) &&
            (identical(other.skippedCount, skippedCount) ||
                other.skippedCount == skippedCount) &&
            (identical(other.adapterMode, adapterMode) ||
                other.adapterMode == adapterMode) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality().equals(other._results, _results));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      processed,
      importedCount,
      totalRows,
      skippedCount,
      adapterMode,
      summary,
      const DeepCollectionEquality().hash(_results));

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
      @JsonKey(name: 'importedCount') final int? importedCount,
      @JsonKey(name: 'totalRows') final int? totalRows,
      @JsonKey(name: 'skippedCount') final int? skippedCount,
      final String? adapterMode,
      final ReconciliationSummary? summary,
      final List<BatchReconResult> results}) = _$GrnImportResultImpl;

  factory _GrnImportResult.fromJson(Map<String, dynamic> json) =
      _$GrnImportResultImpl.fromJson;

  @override
  int? get processed;
  @override
  @JsonKey(name: 'importedCount')
  int? get importedCount;
  @override
  @JsonKey(name: 'totalRows')
  int? get totalRows;
  @override
  @JsonKey(name: 'skippedCount')
  int? get skippedCount;
  @override
  String? get adapterMode;
  @override
  ReconciliationSummary? get summary;
  @override
  List<BatchReconResult> get results;

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
