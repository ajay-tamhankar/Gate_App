// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReportFilter _$ReportFilterFromJson(Map<String, dynamic> json) {
  return _ReportFilter.fromJson(json);
}

/// @nodoc
mixin _$ReportFilter {
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String? get vendorFilter => throw _privateConstructorUsedError;
  String? get poFilter => throw _privateConstructorUsedError;

  /// Serializes this ReportFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReportFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReportFilterCopyWith<ReportFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReportFilterCopyWith<$Res> {
  factory $ReportFilterCopyWith(
          ReportFilter value, $Res Function(ReportFilter) then) =
      _$ReportFilterCopyWithImpl<$Res, ReportFilter>;
  @useResult
  $Res call(
      {DateTime? startDate,
      DateTime? endDate,
      String? vendorFilter,
      String? poFilter});
}

/// @nodoc
class _$ReportFilterCopyWithImpl<$Res, $Val extends ReportFilter>
    implements $ReportFilterCopyWith<$Res> {
  _$ReportFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReportFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? vendorFilter = freezed,
    Object? poFilter = freezed,
  }) {
    return _then(_value.copyWith(
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vendorFilter: freezed == vendorFilter
          ? _value.vendorFilter
          : vendorFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      poFilter: freezed == poFilter
          ? _value.poFilter
          : poFilter // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReportFilterImplCopyWith<$Res>
    implements $ReportFilterCopyWith<$Res> {
  factory _$$ReportFilterImplCopyWith(
          _$ReportFilterImpl value, $Res Function(_$ReportFilterImpl) then) =
      __$$ReportFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime? startDate,
      DateTime? endDate,
      String? vendorFilter,
      String? poFilter});
}

/// @nodoc
class __$$ReportFilterImplCopyWithImpl<$Res>
    extends _$ReportFilterCopyWithImpl<$Res, _$ReportFilterImpl>
    implements _$$ReportFilterImplCopyWith<$Res> {
  __$$ReportFilterImplCopyWithImpl(
      _$ReportFilterImpl _value, $Res Function(_$ReportFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReportFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? vendorFilter = freezed,
    Object? poFilter = freezed,
  }) {
    return _then(_$ReportFilterImpl(
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vendorFilter: freezed == vendorFilter
          ? _value.vendorFilter
          : vendorFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      poFilter: freezed == poFilter
          ? _value.poFilter
          : poFilter // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReportFilterImpl implements _ReportFilter {
  const _$ReportFilterImpl(
      {this.startDate, this.endDate, this.vendorFilter, this.poFilter});

  factory _$ReportFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReportFilterImplFromJson(json);

  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final String? vendorFilter;
  @override
  final String? poFilter;

  @override
  String toString() {
    return 'ReportFilter(startDate: $startDate, endDate: $endDate, vendorFilter: $vendorFilter, poFilter: $poFilter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReportFilterImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.vendorFilter, vendorFilter) ||
                other.vendorFilter == vendorFilter) &&
            (identical(other.poFilter, poFilter) ||
                other.poFilter == poFilter));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, startDate, endDate, vendorFilter, poFilter);

  /// Create a copy of ReportFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReportFilterImplCopyWith<_$ReportFilterImpl> get copyWith =>
      __$$ReportFilterImplCopyWithImpl<_$ReportFilterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReportFilterImplToJson(
      this,
    );
  }
}

abstract class _ReportFilter implements ReportFilter {
  const factory _ReportFilter(
      {final DateTime? startDate,
      final DateTime? endDate,
      final String? vendorFilter,
      final String? poFilter}) = _$ReportFilterImpl;

  factory _ReportFilter.fromJson(Map<String, dynamic> json) =
      _$ReportFilterImpl.fromJson;

  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  String? get vendorFilter;
  @override
  String? get poFilter;

  /// Create a copy of ReportFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReportFilterImplCopyWith<_$ReportFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GateEntryReportItem _$GateEntryReportItemFromJson(Map<String, dynamic> json) {
  return _GateEntryReportItem.fromJson(json);
}

/// @nodoc
mixin _$GateEntryReportItem {
  String get gateEntryNo => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get vendor => throw _privateConstructorUsedError;
  String get poNumber => throw _privateConstructorUsedError;
  String get vehicleNo => throw _privateConstructorUsedError;
  String get material => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this GateEntryReportItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GateEntryReportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GateEntryReportItemCopyWith<GateEntryReportItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GateEntryReportItemCopyWith<$Res> {
  factory $GateEntryReportItemCopyWith(
          GateEntryReportItem value, $Res Function(GateEntryReportItem) then) =
      _$GateEntryReportItemCopyWithImpl<$Res, GateEntryReportItem>;
  @useResult
  $Res call(
      {String gateEntryNo,
      DateTime date,
      String vendor,
      String poNumber,
      String vehicleNo,
      String material,
      String status});
}

/// @nodoc
class _$GateEntryReportItemCopyWithImpl<$Res, $Val extends GateEntryReportItem>
    implements $GateEntryReportItemCopyWith<$Res> {
  _$GateEntryReportItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GateEntryReportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gateEntryNo = null,
    Object? date = null,
    Object? vendor = null,
    Object? poNumber = null,
    Object? vehicleNo = null,
    Object? material = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      gateEntryNo: null == gateEntryNo
          ? _value.gateEntryNo
          : gateEntryNo // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      vendor: null == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as String,
      poNumber: null == poNumber
          ? _value.poNumber
          : poNumber // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleNo: null == vehicleNo
          ? _value.vehicleNo
          : vehicleNo // ignore: cast_nullable_to_non_nullable
              as String,
      material: null == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GateEntryReportItemImplCopyWith<$Res>
    implements $GateEntryReportItemCopyWith<$Res> {
  factory _$$GateEntryReportItemImplCopyWith(_$GateEntryReportItemImpl value,
          $Res Function(_$GateEntryReportItemImpl) then) =
      __$$GateEntryReportItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String gateEntryNo,
      DateTime date,
      String vendor,
      String poNumber,
      String vehicleNo,
      String material,
      String status});
}

/// @nodoc
class __$$GateEntryReportItemImplCopyWithImpl<$Res>
    extends _$GateEntryReportItemCopyWithImpl<$Res, _$GateEntryReportItemImpl>
    implements _$$GateEntryReportItemImplCopyWith<$Res> {
  __$$GateEntryReportItemImplCopyWithImpl(_$GateEntryReportItemImpl _value,
      $Res Function(_$GateEntryReportItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of GateEntryReportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gateEntryNo = null,
    Object? date = null,
    Object? vendor = null,
    Object? poNumber = null,
    Object? vehicleNo = null,
    Object? material = null,
    Object? status = null,
  }) {
    return _then(_$GateEntryReportItemImpl(
      gateEntryNo: null == gateEntryNo
          ? _value.gateEntryNo
          : gateEntryNo // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      vendor: null == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as String,
      poNumber: null == poNumber
          ? _value.poNumber
          : poNumber // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleNo: null == vehicleNo
          ? _value.vehicleNo
          : vehicleNo // ignore: cast_nullable_to_non_nullable
              as String,
      material: null == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GateEntryReportItemImpl implements _GateEntryReportItem {
  const _$GateEntryReportItemImpl(
      {required this.gateEntryNo,
      required this.date,
      required this.vendor,
      required this.poNumber,
      required this.vehicleNo,
      required this.material,
      required this.status});

  factory _$GateEntryReportItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$GateEntryReportItemImplFromJson(json);

  @override
  final String gateEntryNo;
  @override
  final DateTime date;
  @override
  final String vendor;
  @override
  final String poNumber;
  @override
  final String vehicleNo;
  @override
  final String material;
  @override
  final String status;

  @override
  String toString() {
    return 'GateEntryReportItem(gateEntryNo: $gateEntryNo, date: $date, vendor: $vendor, poNumber: $poNumber, vehicleNo: $vehicleNo, material: $material, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GateEntryReportItemImpl &&
            (identical(other.gateEntryNo, gateEntryNo) ||
                other.gateEntryNo == gateEntryNo) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.poNumber, poNumber) ||
                other.poNumber == poNumber) &&
            (identical(other.vehicleNo, vehicleNo) ||
                other.vehicleNo == vehicleNo) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gateEntryNo, date, vendor,
      poNumber, vehicleNo, material, status);

  /// Create a copy of GateEntryReportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GateEntryReportItemImplCopyWith<_$GateEntryReportItemImpl> get copyWith =>
      __$$GateEntryReportItemImplCopyWithImpl<_$GateEntryReportItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GateEntryReportItemImplToJson(
      this,
    );
  }
}

abstract class _GateEntryReportItem implements GateEntryReportItem {
  const factory _GateEntryReportItem(
      {required final String gateEntryNo,
      required final DateTime date,
      required final String vendor,
      required final String poNumber,
      required final String vehicleNo,
      required final String material,
      required final String status}) = _$GateEntryReportItemImpl;

  factory _GateEntryReportItem.fromJson(Map<String, dynamic> json) =
      _$GateEntryReportItemImpl.fromJson;

  @override
  String get gateEntryNo;
  @override
  DateTime get date;
  @override
  String get vendor;
  @override
  String get poNumber;
  @override
  String get vehicleNo;
  @override
  String get material;
  @override
  String get status;

  /// Create a copy of GateEntryReportItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GateEntryReportItemImplCopyWith<_$GateEntryReportItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GrnReconReportItem _$GrnReconReportItemFromJson(Map<String, dynamic> json) {
  return _GrnReconReportItem.fromJson(json);
}

/// @nodoc
mixin _$GrnReconReportItem {
  String get gateEntryNo => throw _privateConstructorUsedError;
  String get grnNo => throw _privateConstructorUsedError;
  String get poNumber => throw _privateConstructorUsedError;
  String get challanNo => throw _privateConstructorUsedError;
  String get matchedStatus => throw _privateConstructorUsedError;
  double get quantityDiff => throw _privateConstructorUsedError;

  /// Serializes this GrnReconReportItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GrnReconReportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GrnReconReportItemCopyWith<GrnReconReportItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GrnReconReportItemCopyWith<$Res> {
  factory $GrnReconReportItemCopyWith(
          GrnReconReportItem value, $Res Function(GrnReconReportItem) then) =
      _$GrnReconReportItemCopyWithImpl<$Res, GrnReconReportItem>;
  @useResult
  $Res call(
      {String gateEntryNo,
      String grnNo,
      String poNumber,
      String challanNo,
      String matchedStatus,
      double quantityDiff});
}

/// @nodoc
class _$GrnReconReportItemCopyWithImpl<$Res, $Val extends GrnReconReportItem>
    implements $GrnReconReportItemCopyWith<$Res> {
  _$GrnReconReportItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GrnReconReportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gateEntryNo = null,
    Object? grnNo = null,
    Object? poNumber = null,
    Object? challanNo = null,
    Object? matchedStatus = null,
    Object? quantityDiff = null,
  }) {
    return _then(_value.copyWith(
      gateEntryNo: null == gateEntryNo
          ? _value.gateEntryNo
          : gateEntryNo // ignore: cast_nullable_to_non_nullable
              as String,
      grnNo: null == grnNo
          ? _value.grnNo
          : grnNo // ignore: cast_nullable_to_non_nullable
              as String,
      poNumber: null == poNumber
          ? _value.poNumber
          : poNumber // ignore: cast_nullable_to_non_nullable
              as String,
      challanNo: null == challanNo
          ? _value.challanNo
          : challanNo // ignore: cast_nullable_to_non_nullable
              as String,
      matchedStatus: null == matchedStatus
          ? _value.matchedStatus
          : matchedStatus // ignore: cast_nullable_to_non_nullable
              as String,
      quantityDiff: null == quantityDiff
          ? _value.quantityDiff
          : quantityDiff // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GrnReconReportItemImplCopyWith<$Res>
    implements $GrnReconReportItemCopyWith<$Res> {
  factory _$$GrnReconReportItemImplCopyWith(_$GrnReconReportItemImpl value,
          $Res Function(_$GrnReconReportItemImpl) then) =
      __$$GrnReconReportItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String gateEntryNo,
      String grnNo,
      String poNumber,
      String challanNo,
      String matchedStatus,
      double quantityDiff});
}

/// @nodoc
class __$$GrnReconReportItemImplCopyWithImpl<$Res>
    extends _$GrnReconReportItemCopyWithImpl<$Res, _$GrnReconReportItemImpl>
    implements _$$GrnReconReportItemImplCopyWith<$Res> {
  __$$GrnReconReportItemImplCopyWithImpl(_$GrnReconReportItemImpl _value,
      $Res Function(_$GrnReconReportItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of GrnReconReportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gateEntryNo = null,
    Object? grnNo = null,
    Object? poNumber = null,
    Object? challanNo = null,
    Object? matchedStatus = null,
    Object? quantityDiff = null,
  }) {
    return _then(_$GrnReconReportItemImpl(
      gateEntryNo: null == gateEntryNo
          ? _value.gateEntryNo
          : gateEntryNo // ignore: cast_nullable_to_non_nullable
              as String,
      grnNo: null == grnNo
          ? _value.grnNo
          : grnNo // ignore: cast_nullable_to_non_nullable
              as String,
      poNumber: null == poNumber
          ? _value.poNumber
          : poNumber // ignore: cast_nullable_to_non_nullable
              as String,
      challanNo: null == challanNo
          ? _value.challanNo
          : challanNo // ignore: cast_nullable_to_non_nullable
              as String,
      matchedStatus: null == matchedStatus
          ? _value.matchedStatus
          : matchedStatus // ignore: cast_nullable_to_non_nullable
              as String,
      quantityDiff: null == quantityDiff
          ? _value.quantityDiff
          : quantityDiff // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GrnReconReportItemImpl implements _GrnReconReportItem {
  const _$GrnReconReportItemImpl(
      {required this.gateEntryNo,
      required this.grnNo,
      required this.poNumber,
      required this.challanNo,
      required this.matchedStatus,
      required this.quantityDiff});

  factory _$GrnReconReportItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$GrnReconReportItemImplFromJson(json);

  @override
  final String gateEntryNo;
  @override
  final String grnNo;
  @override
  final String poNumber;
  @override
  final String challanNo;
  @override
  final String matchedStatus;
  @override
  final double quantityDiff;

  @override
  String toString() {
    return 'GrnReconReportItem(gateEntryNo: $gateEntryNo, grnNo: $grnNo, poNumber: $poNumber, challanNo: $challanNo, matchedStatus: $matchedStatus, quantityDiff: $quantityDiff)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GrnReconReportItemImpl &&
            (identical(other.gateEntryNo, gateEntryNo) ||
                other.gateEntryNo == gateEntryNo) &&
            (identical(other.grnNo, grnNo) || other.grnNo == grnNo) &&
            (identical(other.poNumber, poNumber) ||
                other.poNumber == poNumber) &&
            (identical(other.challanNo, challanNo) ||
                other.challanNo == challanNo) &&
            (identical(other.matchedStatus, matchedStatus) ||
                other.matchedStatus == matchedStatus) &&
            (identical(other.quantityDiff, quantityDiff) ||
                other.quantityDiff == quantityDiff));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, gateEntryNo, grnNo, poNumber,
      challanNo, matchedStatus, quantityDiff);

  /// Create a copy of GrnReconReportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GrnReconReportItemImplCopyWith<_$GrnReconReportItemImpl> get copyWith =>
      __$$GrnReconReportItemImplCopyWithImpl<_$GrnReconReportItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GrnReconReportItemImplToJson(
      this,
    );
  }
}

abstract class _GrnReconReportItem implements GrnReconReportItem {
  const factory _GrnReconReportItem(
      {required final String gateEntryNo,
      required final String grnNo,
      required final String poNumber,
      required final String challanNo,
      required final String matchedStatus,
      required final double quantityDiff}) = _$GrnReconReportItemImpl;

  factory _GrnReconReportItem.fromJson(Map<String, dynamic> json) =
      _$GrnReconReportItemImpl.fromJson;

  @override
  String get gateEntryNo;
  @override
  String get grnNo;
  @override
  String get poNumber;
  @override
  String get challanNo;
  @override
  String get matchedStatus;
  @override
  double get quantityDiff;

  /// Create a copy of GrnReconReportItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GrnReconReportItemImplCopyWith<_$GrnReconReportItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PendingGrnReportItem _$PendingGrnReportItemFromJson(Map<String, dynamic> json) {
  return _PendingGrnReportItem.fromJson(json);
}

/// @nodoc
mixin _$PendingGrnReportItem {
  String get gateEntryNo => throw _privateConstructorUsedError;
  String get poNumber => throw _privateConstructorUsedError;
  String get vendor => throw _privateConstructorUsedError;
  String get material => throw _privateConstructorUsedError;
  int get daysPending => throw _privateConstructorUsedError;

  /// Serializes this PendingGrnReportItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PendingGrnReportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PendingGrnReportItemCopyWith<PendingGrnReportItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PendingGrnReportItemCopyWith<$Res> {
  factory $PendingGrnReportItemCopyWith(PendingGrnReportItem value,
          $Res Function(PendingGrnReportItem) then) =
      _$PendingGrnReportItemCopyWithImpl<$Res, PendingGrnReportItem>;
  @useResult
  $Res call(
      {String gateEntryNo,
      String poNumber,
      String vendor,
      String material,
      int daysPending});
}

/// @nodoc
class _$PendingGrnReportItemCopyWithImpl<$Res,
        $Val extends PendingGrnReportItem>
    implements $PendingGrnReportItemCopyWith<$Res> {
  _$PendingGrnReportItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PendingGrnReportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gateEntryNo = null,
    Object? poNumber = null,
    Object? vendor = null,
    Object? material = null,
    Object? daysPending = null,
  }) {
    return _then(_value.copyWith(
      gateEntryNo: null == gateEntryNo
          ? _value.gateEntryNo
          : gateEntryNo // ignore: cast_nullable_to_non_nullable
              as String,
      poNumber: null == poNumber
          ? _value.poNumber
          : poNumber // ignore: cast_nullable_to_non_nullable
              as String,
      vendor: null == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as String,
      material: null == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String,
      daysPending: null == daysPending
          ? _value.daysPending
          : daysPending // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PendingGrnReportItemImplCopyWith<$Res>
    implements $PendingGrnReportItemCopyWith<$Res> {
  factory _$$PendingGrnReportItemImplCopyWith(_$PendingGrnReportItemImpl value,
          $Res Function(_$PendingGrnReportItemImpl) then) =
      __$$PendingGrnReportItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String gateEntryNo,
      String poNumber,
      String vendor,
      String material,
      int daysPending});
}

/// @nodoc
class __$$PendingGrnReportItemImplCopyWithImpl<$Res>
    extends _$PendingGrnReportItemCopyWithImpl<$Res, _$PendingGrnReportItemImpl>
    implements _$$PendingGrnReportItemImplCopyWith<$Res> {
  __$$PendingGrnReportItemImplCopyWithImpl(_$PendingGrnReportItemImpl _value,
      $Res Function(_$PendingGrnReportItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of PendingGrnReportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gateEntryNo = null,
    Object? poNumber = null,
    Object? vendor = null,
    Object? material = null,
    Object? daysPending = null,
  }) {
    return _then(_$PendingGrnReportItemImpl(
      gateEntryNo: null == gateEntryNo
          ? _value.gateEntryNo
          : gateEntryNo // ignore: cast_nullable_to_non_nullable
              as String,
      poNumber: null == poNumber
          ? _value.poNumber
          : poNumber // ignore: cast_nullable_to_non_nullable
              as String,
      vendor: null == vendor
          ? _value.vendor
          : vendor // ignore: cast_nullable_to_non_nullable
              as String,
      material: null == material
          ? _value.material
          : material // ignore: cast_nullable_to_non_nullable
              as String,
      daysPending: null == daysPending
          ? _value.daysPending
          : daysPending // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PendingGrnReportItemImpl implements _PendingGrnReportItem {
  const _$PendingGrnReportItemImpl(
      {required this.gateEntryNo,
      required this.poNumber,
      required this.vendor,
      required this.material,
      required this.daysPending});

  factory _$PendingGrnReportItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$PendingGrnReportItemImplFromJson(json);

  @override
  final String gateEntryNo;
  @override
  final String poNumber;
  @override
  final String vendor;
  @override
  final String material;
  @override
  final int daysPending;

  @override
  String toString() {
    return 'PendingGrnReportItem(gateEntryNo: $gateEntryNo, poNumber: $poNumber, vendor: $vendor, material: $material, daysPending: $daysPending)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PendingGrnReportItemImpl &&
            (identical(other.gateEntryNo, gateEntryNo) ||
                other.gateEntryNo == gateEntryNo) &&
            (identical(other.poNumber, poNumber) ||
                other.poNumber == poNumber) &&
            (identical(other.vendor, vendor) || other.vendor == vendor) &&
            (identical(other.material, material) ||
                other.material == material) &&
            (identical(other.daysPending, daysPending) ||
                other.daysPending == daysPending));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, gateEntryNo, poNumber, vendor, material, daysPending);

  /// Create a copy of PendingGrnReportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PendingGrnReportItemImplCopyWith<_$PendingGrnReportItemImpl>
      get copyWith =>
          __$$PendingGrnReportItemImplCopyWithImpl<_$PendingGrnReportItemImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PendingGrnReportItemImplToJson(
      this,
    );
  }
}

abstract class _PendingGrnReportItem implements PendingGrnReportItem {
  const factory _PendingGrnReportItem(
      {required final String gateEntryNo,
      required final String poNumber,
      required final String vendor,
      required final String material,
      required final int daysPending}) = _$PendingGrnReportItemImpl;

  factory _PendingGrnReportItem.fromJson(Map<String, dynamic> json) =
      _$PendingGrnReportItemImpl.fromJson;

  @override
  String get gateEntryNo;
  @override
  String get poNumber;
  @override
  String get vendor;
  @override
  String get material;
  @override
  int get daysPending;

  /// Create a copy of PendingGrnReportItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PendingGrnReportItemImplCopyWith<_$PendingGrnReportItemImpl>
      get copyWith => throw _privateConstructorUsedError;
}

AuditTrailReportItem _$AuditTrailReportItemFromJson(Map<String, dynamic> json) {
  return _AuditTrailReportItem.fromJson(json);
}

/// @nodoc
mixin _$AuditTrailReportItem {
  DateTime get date => throw _privateConstructorUsedError;
  String get user => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  String get entity => throw _privateConstructorUsedError;
  String get changes => throw _privateConstructorUsedError;

  /// Serializes this AuditTrailReportItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuditTrailReportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditTrailReportItemCopyWith<AuditTrailReportItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditTrailReportItemCopyWith<$Res> {
  factory $AuditTrailReportItemCopyWith(AuditTrailReportItem value,
          $Res Function(AuditTrailReportItem) then) =
      _$AuditTrailReportItemCopyWithImpl<$Res, AuditTrailReportItem>;
  @useResult
  $Res call(
      {DateTime date,
      String user,
      String action,
      String entity,
      String changes});
}

/// @nodoc
class _$AuditTrailReportItemCopyWithImpl<$Res,
        $Val extends AuditTrailReportItem>
    implements $AuditTrailReportItemCopyWith<$Res> {
  _$AuditTrailReportItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditTrailReportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? user = null,
    Object? action = null,
    Object? entity = null,
    Object? changes = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      entity: null == entity
          ? _value.entity
          : entity // ignore: cast_nullable_to_non_nullable
              as String,
      changes: null == changes
          ? _value.changes
          : changes // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuditTrailReportItemImplCopyWith<$Res>
    implements $AuditTrailReportItemCopyWith<$Res> {
  factory _$$AuditTrailReportItemImplCopyWith(_$AuditTrailReportItemImpl value,
          $Res Function(_$AuditTrailReportItemImpl) then) =
      __$$AuditTrailReportItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      String user,
      String action,
      String entity,
      String changes});
}

/// @nodoc
class __$$AuditTrailReportItemImplCopyWithImpl<$Res>
    extends _$AuditTrailReportItemCopyWithImpl<$Res, _$AuditTrailReportItemImpl>
    implements _$$AuditTrailReportItemImplCopyWith<$Res> {
  __$$AuditTrailReportItemImplCopyWithImpl(_$AuditTrailReportItemImpl _value,
      $Res Function(_$AuditTrailReportItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuditTrailReportItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? user = null,
    Object? action = null,
    Object? entity = null,
    Object? changes = null,
  }) {
    return _then(_$AuditTrailReportItemImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      action: null == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as String,
      entity: null == entity
          ? _value.entity
          : entity // ignore: cast_nullable_to_non_nullable
              as String,
      changes: null == changes
          ? _value.changes
          : changes // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuditTrailReportItemImpl implements _AuditTrailReportItem {
  const _$AuditTrailReportItemImpl(
      {required this.date,
      required this.user,
      required this.action,
      required this.entity,
      required this.changes});

  factory _$AuditTrailReportItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditTrailReportItemImplFromJson(json);

  @override
  final DateTime date;
  @override
  final String user;
  @override
  final String action;
  @override
  final String entity;
  @override
  final String changes;

  @override
  String toString() {
    return 'AuditTrailReportItem(date: $date, user: $user, action: $action, entity: $entity, changes: $changes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditTrailReportItemImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.entity, entity) || other.entity == entity) &&
            (identical(other.changes, changes) || other.changes == changes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, date, user, action, entity, changes);

  /// Create a copy of AuditTrailReportItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditTrailReportItemImplCopyWith<_$AuditTrailReportItemImpl>
      get copyWith =>
          __$$AuditTrailReportItemImplCopyWithImpl<_$AuditTrailReportItemImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditTrailReportItemImplToJson(
      this,
    );
  }
}

abstract class _AuditTrailReportItem implements AuditTrailReportItem {
  const factory _AuditTrailReportItem(
      {required final DateTime date,
      required final String user,
      required final String action,
      required final String entity,
      required final String changes}) = _$AuditTrailReportItemImpl;

  factory _AuditTrailReportItem.fromJson(Map<String, dynamic> json) =
      _$AuditTrailReportItemImpl.fromJson;

  @override
  DateTime get date;
  @override
  String get user;
  @override
  String get action;
  @override
  String get entity;
  @override
  String get changes;

  /// Create a copy of AuditTrailReportItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditTrailReportItemImplCopyWith<_$AuditTrailReportItemImpl>
      get copyWith => throw _privateConstructorUsedError;
}
