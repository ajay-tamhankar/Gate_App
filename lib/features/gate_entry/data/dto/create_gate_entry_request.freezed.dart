// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_gate_entry_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CreateGateEntryRequest _$CreateGateEntryRequestFromJson(
    Map<String, dynamic> json) {
  return _CreateGateEntryRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateGateEntryRequest {
  String get challanNo => throw _privateConstructorUsedError;
  String get vendorName => throw _privateConstructorUsedError;
  String get vehicleNo => throw _privateConstructorUsedError;
  String get transporterName => throw _privateConstructorUsedError;
  String get gateMovement => throw _privateConstructorUsedError;
  List<GateEntryItemResponse> get items => throw _privateConstructorUsedError;

  /// Serializes this CreateGateEntryRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateGateEntryRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateGateEntryRequestCopyWith<CreateGateEntryRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateGateEntryRequestCopyWith<$Res> {
  factory $CreateGateEntryRequestCopyWith(CreateGateEntryRequest value,
          $Res Function(CreateGateEntryRequest) then) =
      _$CreateGateEntryRequestCopyWithImpl<$Res, CreateGateEntryRequest>;
  @useResult
  $Res call(
      {String challanNo,
      String vendorName,
      String vehicleNo,
      String transporterName,
      String gateMovement,
      List<GateEntryItemResponse> items});
}

/// @nodoc
class _$CreateGateEntryRequestCopyWithImpl<$Res,
        $Val extends CreateGateEntryRequest>
    implements $CreateGateEntryRequestCopyWith<$Res> {
  _$CreateGateEntryRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateGateEntryRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challanNo = null,
    Object? vendorName = null,
    Object? vehicleNo = null,
    Object? transporterName = null,
    Object? gateMovement = null,
    Object? items = null,
  }) {
    return _then(_value.copyWith(
      challanNo: null == challanNo
          ? _value.challanNo
          : challanNo // ignore: cast_nullable_to_non_nullable
              as String,
      vendorName: null == vendorName
          ? _value.vendorName
          : vendorName // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleNo: null == vehicleNo
          ? _value.vehicleNo
          : vehicleNo // ignore: cast_nullable_to_non_nullable
              as String,
      transporterName: null == transporterName
          ? _value.transporterName
          : transporterName // ignore: cast_nullable_to_non_nullable
              as String,
      gateMovement: null == gateMovement
          ? _value.gateMovement
          : gateMovement // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<GateEntryItemResponse>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateGateEntryRequestImplCopyWith<$Res>
    implements $CreateGateEntryRequestCopyWith<$Res> {
  factory _$$CreateGateEntryRequestImplCopyWith(
          _$CreateGateEntryRequestImpl value,
          $Res Function(_$CreateGateEntryRequestImpl) then) =
      __$$CreateGateEntryRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String challanNo,
      String vendorName,
      String vehicleNo,
      String transporterName,
      String gateMovement,
      List<GateEntryItemResponse> items});
}

/// @nodoc
class __$$CreateGateEntryRequestImplCopyWithImpl<$Res>
    extends _$CreateGateEntryRequestCopyWithImpl<$Res,
        _$CreateGateEntryRequestImpl>
    implements _$$CreateGateEntryRequestImplCopyWith<$Res> {
  __$$CreateGateEntryRequestImplCopyWithImpl(
      _$CreateGateEntryRequestImpl _value,
      $Res Function(_$CreateGateEntryRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateGateEntryRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challanNo = null,
    Object? vendorName = null,
    Object? vehicleNo = null,
    Object? transporterName = null,
    Object? gateMovement = null,
    Object? items = null,
  }) {
    return _then(_$CreateGateEntryRequestImpl(
      challanNo: null == challanNo
          ? _value.challanNo
          : challanNo // ignore: cast_nullable_to_non_nullable
              as String,
      vendorName: null == vendorName
          ? _value.vendorName
          : vendorName // ignore: cast_nullable_to_non_nullable
              as String,
      vehicleNo: null == vehicleNo
          ? _value.vehicleNo
          : vehicleNo // ignore: cast_nullable_to_non_nullable
              as String,
      transporterName: null == transporterName
          ? _value.transporterName
          : transporterName // ignore: cast_nullable_to_non_nullable
              as String,
      gateMovement: null == gateMovement
          ? _value.gateMovement
          : gateMovement // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<GateEntryItemResponse>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateGateEntryRequestImpl implements _CreateGateEntryRequest {
  const _$CreateGateEntryRequestImpl(
      {required this.challanNo,
      required this.vendorName,
      required this.vehicleNo,
      required this.transporterName,
      required this.gateMovement,
      required final List<GateEntryItemResponse> items})
      : _items = items;

  factory _$CreateGateEntryRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateGateEntryRequestImplFromJson(json);

  @override
  final String challanNo;
  @override
  final String vendorName;
  @override
  final String vehicleNo;
  @override
  final String transporterName;
  @override
  final String gateMovement;
  final List<GateEntryItemResponse> _items;
  @override
  List<GateEntryItemResponse> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'CreateGateEntryRequest(challanNo: $challanNo, vendorName: $vendorName, vehicleNo: $vehicleNo, transporterName: $transporterName, gateMovement: $gateMovement, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateGateEntryRequestImpl &&
            (identical(other.challanNo, challanNo) ||
                other.challanNo == challanNo) &&
            (identical(other.vendorName, vendorName) ||
                other.vendorName == vendorName) &&
            (identical(other.vehicleNo, vehicleNo) ||
                other.vehicleNo == vehicleNo) &&
            (identical(other.transporterName, transporterName) ||
                other.transporterName == transporterName) &&
            (identical(other.gateMovement, gateMovement) ||
                other.gateMovement == gateMovement) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      challanNo,
      vendorName,
      vehicleNo,
      transporterName,
      gateMovement,
      const DeepCollectionEquality().hash(_items));

  /// Create a copy of CreateGateEntryRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateGateEntryRequestImplCopyWith<_$CreateGateEntryRequestImpl>
      get copyWith => __$$CreateGateEntryRequestImplCopyWithImpl<
          _$CreateGateEntryRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateGateEntryRequestImplToJson(
      this,
    );
  }
}

abstract class _CreateGateEntryRequest implements CreateGateEntryRequest {
  const factory _CreateGateEntryRequest(
          {required final String challanNo,
          required final String vendorName,
          required final String vehicleNo,
          required final String transporterName,
          required final String gateMovement,
          required final List<GateEntryItemResponse> items}) =
      _$CreateGateEntryRequestImpl;

  factory _CreateGateEntryRequest.fromJson(Map<String, dynamic> json) =
      _$CreateGateEntryRequestImpl.fromJson;

  @override
  String get challanNo;
  @override
  String get vendorName;
  @override
  String get vehicleNo;
  @override
  String get transporterName;
  @override
  String get gateMovement;
  @override
  List<GateEntryItemResponse> get items;

  /// Create a copy of CreateGateEntryRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateGateEntryRequestImplCopyWith<_$CreateGateEntryRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
