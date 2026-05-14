// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gate_entry_item_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$GateEntryItemResponse {
  String? get id => throw _privateConstructorUsedError;
  String get poNumber => throw _privateConstructorUsedError;
  String get materialCode => throw _privateConstructorUsedError;
  int get challanQty => throw _privateConstructorUsedError;
  String get uom => throw _privateConstructorUsedError;
  String? get challanNo => throw _privateConstructorUsedError;

  /// Create a copy of GateEntryItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GateEntryItemResponseCopyWith<GateEntryItemResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GateEntryItemResponseCopyWith<$Res> {
  factory $GateEntryItemResponseCopyWith(GateEntryItemResponse value,
          $Res Function(GateEntryItemResponse) then) =
      _$GateEntryItemResponseCopyWithImpl<$Res, GateEntryItemResponse>;
  @useResult
  $Res call(
      {String? id,
      String poNumber,
      String materialCode,
      int challanQty,
      String uom,
      String? challanNo});
}

/// @nodoc
class _$GateEntryItemResponseCopyWithImpl<$Res,
        $Val extends GateEntryItemResponse>
    implements $GateEntryItemResponseCopyWith<$Res> {
  _$GateEntryItemResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GateEntryItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? poNumber = null,
    Object? materialCode = null,
    Object? challanQty = null,
    Object? uom = null,
    Object? challanNo = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      poNumber: null == poNumber
          ? _value.poNumber
          : poNumber // ignore: cast_nullable_to_non_nullable
              as String,
      materialCode: null == materialCode
          ? _value.materialCode
          : materialCode // ignore: cast_nullable_to_non_nullable
              as String,
      challanQty: null == challanQty
          ? _value.challanQty
          : challanQty // ignore: cast_nullable_to_non_nullable
              as int,
      uom: null == uom
          ? _value.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      challanNo: freezed == challanNo
          ? _value.challanNo
          : challanNo // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GateEntryItemResponseImplCopyWith<$Res>
    implements $GateEntryItemResponseCopyWith<$Res> {
  factory _$$GateEntryItemResponseImplCopyWith(
          _$GateEntryItemResponseImpl value,
          $Res Function(_$GateEntryItemResponseImpl) then) =
      __$$GateEntryItemResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String poNumber,
      String materialCode,
      int challanQty,
      String uom,
      String? challanNo});
}

/// @nodoc
class __$$GateEntryItemResponseImplCopyWithImpl<$Res>
    extends _$GateEntryItemResponseCopyWithImpl<$Res,
        _$GateEntryItemResponseImpl>
    implements _$$GateEntryItemResponseImplCopyWith<$Res> {
  __$$GateEntryItemResponseImplCopyWithImpl(_$GateEntryItemResponseImpl _value,
      $Res Function(_$GateEntryItemResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of GateEntryItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? poNumber = null,
    Object? materialCode = null,
    Object? challanQty = null,
    Object? uom = null,
    Object? challanNo = freezed,
  }) {
    return _then(_$GateEntryItemResponseImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      poNumber: null == poNumber
          ? _value.poNumber
          : poNumber // ignore: cast_nullable_to_non_nullable
              as String,
      materialCode: null == materialCode
          ? _value.materialCode
          : materialCode // ignore: cast_nullable_to_non_nullable
              as String,
      challanQty: null == challanQty
          ? _value.challanQty
          : challanQty // ignore: cast_nullable_to_non_nullable
              as int,
      uom: null == uom
          ? _value.uom
          : uom // ignore: cast_nullable_to_non_nullable
              as String,
      challanNo: freezed == challanNo
          ? _value.challanNo
          : challanNo // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$GateEntryItemResponseImpl implements _GateEntryItemResponse {
  const _$GateEntryItemResponseImpl(
      {this.id,
      required this.poNumber,
      required this.materialCode,
      required this.challanQty,
      required this.uom,
      this.challanNo});

  @override
  final String? id;
  @override
  final String poNumber;
  @override
  final String materialCode;
  @override
  final int challanQty;
  @override
  final String uom;
  @override
  final String? challanNo;

  @override
  String toString() {
    return 'GateEntryItemResponse(id: $id, poNumber: $poNumber, materialCode: $materialCode, challanQty: $challanQty, uom: $uom, challanNo: $challanNo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GateEntryItemResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.poNumber, poNumber) ||
                other.poNumber == poNumber) &&
            (identical(other.materialCode, materialCode) ||
                other.materialCode == materialCode) &&
            (identical(other.challanQty, challanQty) ||
                other.challanQty == challanQty) &&
            (identical(other.uom, uom) || other.uom == uom) &&
            (identical(other.challanNo, challanNo) ||
                other.challanNo == challanNo));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, poNumber, materialCode, challanQty, uom, challanNo);

  /// Create a copy of GateEntryItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GateEntryItemResponseImplCopyWith<_$GateEntryItemResponseImpl>
      get copyWith => __$$GateEntryItemResponseImplCopyWithImpl<
          _$GateEntryItemResponseImpl>(this, _$identity);
}

abstract class _GateEntryItemResponse implements GateEntryItemResponse {
  const factory _GateEntryItemResponse(
      {final String? id,
      required final String poNumber,
      required final String materialCode,
      required final int challanQty,
      required final String uom,
      final String? challanNo}) = _$GateEntryItemResponseImpl;

  @override
  String? get id;
  @override
  String get poNumber;
  @override
  String get materialCode;
  @override
  int get challanQty;
  @override
  String get uom;
  @override
  String? get challanNo;

  /// Create a copy of GateEntryItemResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GateEntryItemResponseImplCopyWith<_$GateEntryItemResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
