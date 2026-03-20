// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gate_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GateEntry _$GateEntryFromJson(Map<String, dynamic> json) {
  return _GateEntry.fromJson(json);
}

/// @nodoc
mixin _$GateEntry {
  String get id => throw _privateConstructorUsedError;
  String? get gateEntryNo => throw _privateConstructorUsedError;
  GateMovement get gateMovement => throw _privateConstructorUsedError;
  String get challanNo => throw _privateConstructorUsedError;
  String get transporterName => throw _privateConstructorUsedError;
  String get vehicleNo => throw _privateConstructorUsedError;
  String get vendorName => throw _privateConstructorUsedError;
  List<GateEntryItem> get items => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get gateTimestamp => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;

  /// Serializes this GateEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GateEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GateEntryCopyWith<GateEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GateEntryCopyWith<$Res> {
  factory $GateEntryCopyWith(GateEntry value, $Res Function(GateEntry) then) =
      _$GateEntryCopyWithImpl<$Res, GateEntry>;
  @useResult
  $Res call(
      {String id,
      String? gateEntryNo,
      GateMovement gateMovement,
      String challanNo,
      String transporterName,
      String vehicleNo,
      String vendorName,
      List<GateEntryItem> items,
      String status,
      DateTime? gateTimestamp,
      String? createdBy});
}

/// @nodoc
class _$GateEntryCopyWithImpl<$Res, $Val extends GateEntry>
    implements $GateEntryCopyWith<$Res> {
  _$GateEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GateEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gateEntryNo = freezed,
    Object? gateMovement = null,
    Object? challanNo = null,
    Object? transporterName = null,
    Object? vehicleNo = null,
    Object? vendorName = null,
    Object? items = null,
    Object? status = null,
    Object? gateTimestamp = freezed,
    Object? createdBy = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gateEntryNo: freezed == gateEntryNo
          ? _value.gateEntryNo
          : gateEntryNo // ignore: cast_nullable_to_non_nullable
              as String?,
      gateMovement: null == gateMovement
          ? _value.gateMovement
          : gateMovement // ignore: cast_nullable_to_non_nullable
              as GateMovement,
      challanNo: null == challanNo
          ? _value.challanNo
          : challanNo // ignore: cast_nullable_to_non_nullable
              as String,
      transporterName: null == transporterName
          ? _value.transporterName
          : transporterName // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleNo: null == vehicleNo
          ? _value.vehicleNo
          : vehicleNo // ignore: cast_nullable_to_non_nullable
              as String,
      vendorName: null == vendorName
          ? _value.vendorName
          : vendorName // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<GateEntryItem>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      gateTimestamp: freezed == gateTimestamp
          ? _value.gateTimestamp
          : gateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GateEntryImplCopyWith<$Res>
    implements $GateEntryCopyWith<$Res> {
  factory _$$GateEntryImplCopyWith(
          _$GateEntryImpl value, $Res Function(_$GateEntryImpl) then) =
      __$$GateEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? gateEntryNo,
      GateMovement gateMovement,
      String challanNo,
      String transporterName,
      String vehicleNo,
      String vendorName,
      List<GateEntryItem> items,
      String status,
      DateTime? gateTimestamp,
      String? createdBy});
}

/// @nodoc
class __$$GateEntryImplCopyWithImpl<$Res>
    extends _$GateEntryCopyWithImpl<$Res, _$GateEntryImpl>
    implements _$$GateEntryImplCopyWith<$Res> {
  __$$GateEntryImplCopyWithImpl(
      _$GateEntryImpl _value, $Res Function(_$GateEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of GateEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gateEntryNo = freezed,
    Object? gateMovement = null,
    Object? challanNo = null,
    Object? transporterName = null,
    Object? vehicleNo = null,
    Object? vendorName = null,
    Object? items = null,
    Object? status = null,
    Object? gateTimestamp = freezed,
    Object? createdBy = freezed,
  }) {
    return _then(_$GateEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      gateEntryNo: freezed == gateEntryNo
          ? _value.gateEntryNo
          : gateEntryNo // ignore: cast_nullable_to_non_nullable
              as String?,
      gateMovement: null == gateMovement
          ? _value.gateMovement
          : gateMovement // ignore: cast_nullable_to_non_nullable
              as GateMovement,
      challanNo: null == challanNo
          ? _value.challanNo
          : challanNo // ignore: cast_nullable_to_non_nullable
              as String,
      transporterName: null == transporterName
          ? _value.transporterName
          : transporterName // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleNo: null == vehicleNo
          ? _value.vehicleNo
          : vehicleNo // ignore: cast_nullable_to_non_nullable
              as String,
      vendorName: null == vendorName
          ? _value.vendorName
          : vendorName // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<GateEntryItem>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      gateTimestamp: freezed == gateTimestamp
          ? _value.gateTimestamp
          : gateTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GateEntryImpl implements _GateEntry {
  const _$GateEntryImpl(
      {required this.id,
      this.gateEntryNo,
      required this.gateMovement,
      required this.challanNo,
      required this.transporterName,
      required this.vehicleNo,
      required this.vendorName,
      required final List<GateEntryItem> items,
      this.status = 'Pending',
      this.gateTimestamp,
      this.createdBy})
      : _items = items;

  factory _$GateEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$GateEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String? gateEntryNo;
  @override
  final GateMovement gateMovement;
  @override
  final String challanNo;
  @override
  final String transporterName;
  @override
  final String vehicleNo;
  @override
  final String vendorName;
  final List<GateEntryItem> _items;
  @override
  List<GateEntryItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? gateTimestamp;
  @override
  final String? createdBy;

  @override
  String toString() {
    return 'GateEntry(id: $id, gateEntryNo: $gateEntryNo, gateMovement: $gateMovement, challanNo: $challanNo, transporterName: $transporterName, vehicleNo: $vehicleNo, vendorName: $vendorName, items: $items, status: $status, gateTimestamp: $gateTimestamp, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GateEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gateEntryNo, gateEntryNo) ||
                other.gateEntryNo == gateEntryNo) &&
            (identical(other.gateMovement, gateMovement) ||
                other.gateMovement == gateMovement) &&
            (identical(other.challanNo, challanNo) ||
                other.challanNo == challanNo) &&
            (identical(other.transporterName, transporterName) ||
                other.transporterName == transporterName) &&
            (identical(other.vehicleNo, vehicleNo) ||
                other.vehicleNo == vehicleNo) &&
            (identical(other.vendorName, vendorName) ||
                other.vendorName == vendorName) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.gateTimestamp, gateTimestamp) ||
                other.gateTimestamp == gateTimestamp) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      gateEntryNo,
      gateMovement,
      challanNo,
      transporterName,
      vehicleNo,
      vendorName,
      const DeepCollectionEquality().hash(_items),
      status,
      gateTimestamp,
      createdBy);

  /// Create a copy of GateEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GateEntryImplCopyWith<_$GateEntryImpl> get copyWith =>
      __$$GateEntryImplCopyWithImpl<_$GateEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GateEntryImplToJson(
      this,
    );
  }
}

abstract class _GateEntry implements GateEntry {
  const factory _GateEntry(
      {required final String id,
      final String? gateEntryNo,
      required final GateMovement gateMovement,
      required final String challanNo,
      required final String transporterName,
      required final String vehicleNo,
      required final String vendorName,
      required final List<GateEntryItem> items,
      final String status,
      final DateTime? gateTimestamp,
      final String? createdBy}) = _$GateEntryImpl;

  factory _GateEntry.fromJson(Map<String, dynamic> json) =
      _$GateEntryImpl.fromJson;

  @override
  String get id;
  @override
  String? get gateEntryNo;
  @override
  GateMovement get gateMovement;
  @override
  String get challanNo;
  @override
  String get transporterName;
  @override
  String get vehicleNo;
  @override
  String get vendorName;
  @override
  List<GateEntryItem> get items;
  @override
  String get status;
  @override
  DateTime? get gateTimestamp;
  @override
  String? get createdBy;

  /// Create a copy of GateEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GateEntryImplCopyWith<_$GateEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
