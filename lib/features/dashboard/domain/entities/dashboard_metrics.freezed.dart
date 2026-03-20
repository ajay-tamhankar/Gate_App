// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardMetrics _$DashboardMetricsFromJson(Map<String, dynamic> json) {
  return _DashboardMetrics.fromJson(json);
}

/// @nodoc
mixin _$DashboardMetrics {
  int get totalGateEntriesToday => throw _privateConstructorUsedError;
  int get totalGateEntriesMonth => throw _privateConstructorUsedError;
  int get totalGrnPosted => throw _privateConstructorUsedError;
  int get pendingGrnCount => throw _privateConstructorUsedError;
  int get quantityMismatchCases => throw _privateConstructorUsedError;
  int get duplicateGrnCases => throw _privateConstructorUsedError;
  double get gateTat => throw _privateConstructorUsedError;
  double get dockTat => throw _privateConstructorUsedError;
  int get pendingGrnAging0To1 => throw _privateConstructorUsedError;
  int get pendingGrnAging2To3 => throw _privateConstructorUsedError;
  int get pendingGrnAgingMoreThan3 => throw _privateConstructorUsedError;
  List<DailyActivity> get recentActivity => throw _privateConstructorUsedError;

  /// Serializes this DashboardMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardMetricsCopyWith<DashboardMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardMetricsCopyWith<$Res> {
  factory $DashboardMetricsCopyWith(
          DashboardMetrics value, $Res Function(DashboardMetrics) then) =
      _$DashboardMetricsCopyWithImpl<$Res, DashboardMetrics>;
  @useResult
  $Res call(
      {int totalGateEntriesToday,
      int totalGateEntriesMonth,
      int totalGrnPosted,
      int pendingGrnCount,
      int quantityMismatchCases,
      int duplicateGrnCases,
      double gateTat,
      double dockTat,
      int pendingGrnAging0To1,
      int pendingGrnAging2To3,
      int pendingGrnAgingMoreThan3,
      List<DailyActivity> recentActivity});
}

/// @nodoc
class _$DashboardMetricsCopyWithImpl<$Res, $Val extends DashboardMetrics>
    implements $DashboardMetricsCopyWith<$Res> {
  _$DashboardMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalGateEntriesToday = null,
    Object? totalGateEntriesMonth = null,
    Object? totalGrnPosted = null,
    Object? pendingGrnCount = null,
    Object? quantityMismatchCases = null,
    Object? duplicateGrnCases = null,
    Object? gateTat = null,
    Object? dockTat = null,
    Object? pendingGrnAging0To1 = null,
    Object? pendingGrnAging2To3 = null,
    Object? pendingGrnAgingMoreThan3 = null,
    Object? recentActivity = null,
  }) {
    return _then(_value.copyWith(
      totalGateEntriesToday: null == totalGateEntriesToday
          ? _value.totalGateEntriesToday
          : totalGateEntriesToday // ignore: cast_nullable_to_non_nullable
              as int,
      totalGateEntriesMonth: null == totalGateEntriesMonth
          ? _value.totalGateEntriesMonth
          : totalGateEntriesMonth // ignore: cast_nullable_to_non_nullable
              as int,
      totalGrnPosted: null == totalGrnPosted
          ? _value.totalGrnPosted
          : totalGrnPosted // ignore: cast_nullable_to_non_nullable
              as int,
      pendingGrnCount: null == pendingGrnCount
          ? _value.pendingGrnCount
          : pendingGrnCount // ignore: cast_nullable_to_non_nullable
              as int,
      quantityMismatchCases: null == quantityMismatchCases
          ? _value.quantityMismatchCases
          : quantityMismatchCases // ignore: cast_nullable_to_non_nullable
              as int,
      duplicateGrnCases: null == duplicateGrnCases
          ? _value.duplicateGrnCases
          : duplicateGrnCases // ignore: cast_nullable_to_non_nullable
              as int,
      gateTat: null == gateTat
          ? _value.gateTat
          : gateTat // ignore: cast_nullable_to_non_nullable
              as double,
      dockTat: null == dockTat
          ? _value.dockTat
          : dockTat // ignore: cast_nullable_to_non_nullable
              as double,
      pendingGrnAging0To1: null == pendingGrnAging0To1
          ? _value.pendingGrnAging0To1
          : pendingGrnAging0To1 // ignore: cast_nullable_to_non_nullable
              as int,
      pendingGrnAging2To3: null == pendingGrnAging2To3
          ? _value.pendingGrnAging2To3
          : pendingGrnAging2To3 // ignore: cast_nullable_to_non_nullable
              as int,
      pendingGrnAgingMoreThan3: null == pendingGrnAgingMoreThan3
          ? _value.pendingGrnAgingMoreThan3
          : pendingGrnAgingMoreThan3 // ignore: cast_nullable_to_non_nullable
              as int,
      recentActivity: null == recentActivity
          ? _value.recentActivity
          : recentActivity // ignore: cast_nullable_to_non_nullable
              as List<DailyActivity>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardMetricsImplCopyWith<$Res>
    implements $DashboardMetricsCopyWith<$Res> {
  factory _$$DashboardMetricsImplCopyWith(_$DashboardMetricsImpl value,
          $Res Function(_$DashboardMetricsImpl) then) =
      __$$DashboardMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalGateEntriesToday,
      int totalGateEntriesMonth,
      int totalGrnPosted,
      int pendingGrnCount,
      int quantityMismatchCases,
      int duplicateGrnCases,
      double gateTat,
      double dockTat,
      int pendingGrnAging0To1,
      int pendingGrnAging2To3,
      int pendingGrnAgingMoreThan3,
      List<DailyActivity> recentActivity});
}

/// @nodoc
class __$$DashboardMetricsImplCopyWithImpl<$Res>
    extends _$DashboardMetricsCopyWithImpl<$Res, _$DashboardMetricsImpl>
    implements _$$DashboardMetricsImplCopyWith<$Res> {
  __$$DashboardMetricsImplCopyWithImpl(_$DashboardMetricsImpl _value,
      $Res Function(_$DashboardMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalGateEntriesToday = null,
    Object? totalGateEntriesMonth = null,
    Object? totalGrnPosted = null,
    Object? pendingGrnCount = null,
    Object? quantityMismatchCases = null,
    Object? duplicateGrnCases = null,
    Object? gateTat = null,
    Object? dockTat = null,
    Object? pendingGrnAging0To1 = null,
    Object? pendingGrnAging2To3 = null,
    Object? pendingGrnAgingMoreThan3 = null,
    Object? recentActivity = null,
  }) {
    return _then(_$DashboardMetricsImpl(
      totalGateEntriesToday: null == totalGateEntriesToday
          ? _value.totalGateEntriesToday
          : totalGateEntriesToday // ignore: cast_nullable_to_non_nullable
              as int,
      totalGateEntriesMonth: null == totalGateEntriesMonth
          ? _value.totalGateEntriesMonth
          : totalGateEntriesMonth // ignore: cast_nullable_to_non_nullable
              as int,
      totalGrnPosted: null == totalGrnPosted
          ? _value.totalGrnPosted
          : totalGrnPosted // ignore: cast_nullable_to_non_nullable
              as int,
      pendingGrnCount: null == pendingGrnCount
          ? _value.pendingGrnCount
          : pendingGrnCount // ignore: cast_nullable_to_non_nullable
              as int,
      quantityMismatchCases: null == quantityMismatchCases
          ? _value.quantityMismatchCases
          : quantityMismatchCases // ignore: cast_nullable_to_non_nullable
              as int,
      duplicateGrnCases: null == duplicateGrnCases
          ? _value.duplicateGrnCases
          : duplicateGrnCases // ignore: cast_nullable_to_non_nullable
              as int,
      gateTat: null == gateTat
          ? _value.gateTat
          : gateTat // ignore: cast_nullable_to_non_nullable
              as double,
      dockTat: null == dockTat
          ? _value.dockTat
          : dockTat // ignore: cast_nullable_to_non_nullable
              as double,
      pendingGrnAging0To1: null == pendingGrnAging0To1
          ? _value.pendingGrnAging0To1
          : pendingGrnAging0To1 // ignore: cast_nullable_to_non_nullable
              as int,
      pendingGrnAging2To3: null == pendingGrnAging2To3
          ? _value.pendingGrnAging2To3
          : pendingGrnAging2To3 // ignore: cast_nullable_to_non_nullable
              as int,
      pendingGrnAgingMoreThan3: null == pendingGrnAgingMoreThan3
          ? _value.pendingGrnAgingMoreThan3
          : pendingGrnAgingMoreThan3 // ignore: cast_nullable_to_non_nullable
              as int,
      recentActivity: null == recentActivity
          ? _value._recentActivity
          : recentActivity // ignore: cast_nullable_to_non_nullable
              as List<DailyActivity>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardMetricsImpl implements _DashboardMetrics {
  const _$DashboardMetricsImpl(
      {required this.totalGateEntriesToday,
      required this.totalGateEntriesMonth,
      required this.totalGrnPosted,
      required this.pendingGrnCount,
      required this.quantityMismatchCases,
      required this.duplicateGrnCases,
      required this.gateTat,
      required this.dockTat,
      required this.pendingGrnAging0To1,
      required this.pendingGrnAging2To3,
      required this.pendingGrnAgingMoreThan3,
      required final List<DailyActivity> recentActivity})
      : _recentActivity = recentActivity;

  factory _$DashboardMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardMetricsImplFromJson(json);

  @override
  final int totalGateEntriesToday;
  @override
  final int totalGateEntriesMonth;
  @override
  final int totalGrnPosted;
  @override
  final int pendingGrnCount;
  @override
  final int quantityMismatchCases;
  @override
  final int duplicateGrnCases;
  @override
  final double gateTat;
  @override
  final double dockTat;
  @override
  final int pendingGrnAging0To1;
  @override
  final int pendingGrnAging2To3;
  @override
  final int pendingGrnAgingMoreThan3;
  final List<DailyActivity> _recentActivity;
  @override
  List<DailyActivity> get recentActivity {
    if (_recentActivity is EqualUnmodifiableListView) return _recentActivity;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentActivity);
  }

  @override
  String toString() {
    return 'DashboardMetrics(totalGateEntriesToday: $totalGateEntriesToday, totalGateEntriesMonth: $totalGateEntriesMonth, totalGrnPosted: $totalGrnPosted, pendingGrnCount: $pendingGrnCount, quantityMismatchCases: $quantityMismatchCases, duplicateGrnCases: $duplicateGrnCases, gateTat: $gateTat, dockTat: $dockTat, pendingGrnAging0To1: $pendingGrnAging0To1, pendingGrnAging2To3: $pendingGrnAging2To3, pendingGrnAgingMoreThan3: $pendingGrnAgingMoreThan3, recentActivity: $recentActivity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardMetricsImpl &&
            (identical(other.totalGateEntriesToday, totalGateEntriesToday) ||
                other.totalGateEntriesToday == totalGateEntriesToday) &&
            (identical(other.totalGateEntriesMonth, totalGateEntriesMonth) ||
                other.totalGateEntriesMonth == totalGateEntriesMonth) &&
            (identical(other.totalGrnPosted, totalGrnPosted) ||
                other.totalGrnPosted == totalGrnPosted) &&
            (identical(other.pendingGrnCount, pendingGrnCount) ||
                other.pendingGrnCount == pendingGrnCount) &&
            (identical(other.quantityMismatchCases, quantityMismatchCases) ||
                other.quantityMismatchCases == quantityMismatchCases) &&
            (identical(other.duplicateGrnCases, duplicateGrnCases) ||
                other.duplicateGrnCases == duplicateGrnCases) &&
            (identical(other.gateTat, gateTat) || other.gateTat == gateTat) &&
            (identical(other.dockTat, dockTat) || other.dockTat == dockTat) &&
            (identical(other.pendingGrnAging0To1, pendingGrnAging0To1) ||
                other.pendingGrnAging0To1 == pendingGrnAging0To1) &&
            (identical(other.pendingGrnAging2To3, pendingGrnAging2To3) ||
                other.pendingGrnAging2To3 == pendingGrnAging2To3) &&
            (identical(
                    other.pendingGrnAgingMoreThan3, pendingGrnAgingMoreThan3) ||
                other.pendingGrnAgingMoreThan3 == pendingGrnAgingMoreThan3) &&
            const DeepCollectionEquality()
                .equals(other._recentActivity, _recentActivity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalGateEntriesToday,
      totalGateEntriesMonth,
      totalGrnPosted,
      pendingGrnCount,
      quantityMismatchCases,
      duplicateGrnCases,
      gateTat,
      dockTat,
      pendingGrnAging0To1,
      pendingGrnAging2To3,
      pendingGrnAgingMoreThan3,
      const DeepCollectionEquality().hash(_recentActivity));

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardMetricsImplCopyWith<_$DashboardMetricsImpl> get copyWith =>
      __$$DashboardMetricsImplCopyWithImpl<_$DashboardMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardMetricsImplToJson(
      this,
    );
  }
}

abstract class _DashboardMetrics implements DashboardMetrics {
  const factory _DashboardMetrics(
          {required final int totalGateEntriesToday,
          required final int totalGateEntriesMonth,
          required final int totalGrnPosted,
          required final int pendingGrnCount,
          required final int quantityMismatchCases,
          required final int duplicateGrnCases,
          required final double gateTat,
          required final double dockTat,
          required final int pendingGrnAging0To1,
          required final int pendingGrnAging2To3,
          required final int pendingGrnAgingMoreThan3,
          required final List<DailyActivity> recentActivity}) =
      _$DashboardMetricsImpl;

  factory _DashboardMetrics.fromJson(Map<String, dynamic> json) =
      _$DashboardMetricsImpl.fromJson;

  @override
  int get totalGateEntriesToday;
  @override
  int get totalGateEntriesMonth;
  @override
  int get totalGrnPosted;
  @override
  int get pendingGrnCount;
  @override
  int get quantityMismatchCases;
  @override
  int get duplicateGrnCases;
  @override
  double get gateTat;
  @override
  double get dockTat;
  @override
  int get pendingGrnAging0To1;
  @override
  int get pendingGrnAging2To3;
  @override
  int get pendingGrnAgingMoreThan3;
  @override
  List<DailyActivity> get recentActivity;

  /// Create a copy of DashboardMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardMetricsImplCopyWith<_$DashboardMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyActivity _$DailyActivityFromJson(Map<String, dynamic> json) {
  return _DailyActivity.fromJson(json);
}

/// @nodoc
mixin _$DailyActivity {
  String get day => throw _privateConstructorUsedError;
  int get entriesCount => throw _privateConstructorUsedError;

  /// Serializes this DailyActivity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyActivityCopyWith<DailyActivity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyActivityCopyWith<$Res> {
  factory $DailyActivityCopyWith(
          DailyActivity value, $Res Function(DailyActivity) then) =
      _$DailyActivityCopyWithImpl<$Res, DailyActivity>;
  @useResult
  $Res call({String day, int entriesCount});
}

/// @nodoc
class _$DailyActivityCopyWithImpl<$Res, $Val extends DailyActivity>
    implements $DailyActivityCopyWith<$Res> {
  _$DailyActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? entriesCount = null,
  }) {
    return _then(_value.copyWith(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      entriesCount: null == entriesCount
          ? _value.entriesCount
          : entriesCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyActivityImplCopyWith<$Res>
    implements $DailyActivityCopyWith<$Res> {
  factory _$$DailyActivityImplCopyWith(
          _$DailyActivityImpl value, $Res Function(_$DailyActivityImpl) then) =
      __$$DailyActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String day, int entriesCount});
}

/// @nodoc
class __$$DailyActivityImplCopyWithImpl<$Res>
    extends _$DailyActivityCopyWithImpl<$Res, _$DailyActivityImpl>
    implements _$$DailyActivityImplCopyWith<$Res> {
  __$$DailyActivityImplCopyWithImpl(
      _$DailyActivityImpl _value, $Res Function(_$DailyActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyActivity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? day = null,
    Object? entriesCount = null,
  }) {
    return _then(_$DailyActivityImpl(
      day: null == day
          ? _value.day
          : day // ignore: cast_nullable_to_non_nullable
              as String,
      entriesCount: null == entriesCount
          ? _value.entriesCount
          : entriesCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyActivityImpl implements _DailyActivity {
  const _$DailyActivityImpl({required this.day, required this.entriesCount});

  factory _$DailyActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyActivityImplFromJson(json);

  @override
  final String day;
  @override
  final int entriesCount;

  @override
  String toString() {
    return 'DailyActivity(day: $day, entriesCount: $entriesCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyActivityImpl &&
            (identical(other.day, day) || other.day == day) &&
            (identical(other.entriesCount, entriesCount) ||
                other.entriesCount == entriesCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, day, entriesCount);

  /// Create a copy of DailyActivity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyActivityImplCopyWith<_$DailyActivityImpl> get copyWith =>
      __$$DailyActivityImplCopyWithImpl<_$DailyActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyActivityImplToJson(
      this,
    );
  }
}

abstract class _DailyActivity implements DailyActivity {
  const factory _DailyActivity(
      {required final String day,
      required final int entriesCount}) = _$DailyActivityImpl;

  factory _DailyActivity.fromJson(Map<String, dynamic> json) =
      _$DailyActivityImpl.fromJson;

  @override
  String get day;
  @override
  int get entriesCount;

  /// Create a copy of DailyActivity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyActivityImplCopyWith<_$DailyActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
