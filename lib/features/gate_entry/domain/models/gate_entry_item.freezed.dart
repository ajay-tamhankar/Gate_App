// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gate_entry_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GateEntryItem _$GateEntryItemFromJson(Map<String, dynamic> json) {
  return _GateEntryItem.fromJson(json);
}

/// @nodoc
mixin _$GateEntryItem {
  String? get id => throw _privateConstructorUsedError;
  String get poNumber => throw _privateConstructorUsedError;
  String get materialCode => throw _privateConstructorUsedError;
  int get challanQty => throw _privateConstructorUsedError;
  String get uom => throw _privateConstructorUsedError;

  /// Serializes this GateEntryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GateEntryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GateEntryItemCopyWith<GateEntryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GateEntryItemCopyWith<$Res> {
  factory $GateEntryItemCopyWith(
          GateEntryItem value, $Res Function(GateEntryItem) then) =
      _$GateEntryItemCopyWithImpl<$Res, GateEntryItem>;
  @useResult
  $Res call(
      {String? id,
      String poNumber,
      String materialCode,
      int challanQty,
      String uom});
}

/// @nodoc
class _$GateEntryItemCopyWithImpl<$Res, $Val extends GateEntryItem>
    implements $GateEntryItemCopyWith<$Res> {
  _$GateEntryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GateEntryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? poNumber = null,
    Object? materialCode = null,
    Object? challanQty = null,
    Object? uom = null,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GateEntryItemImplCopyWith<$Res>
    implements $GateEntryItemCopyWith<$Res> {
  factory _$$GateEntryItemImplCopyWith(
          _$GateEntryItemImpl value, $Res Function(_$GateEntryItemImpl) then) =
      __$$GateEntryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String poNumber,
      String materialCode,
      int challanQty,
      String uom});
}

/// @nodoc
class __$$GateEntryItemImplCopyWithImpl<$Res>
    extends _$GateEntryItemCopyWithImpl<$Res, _$GateEntryItemImpl>
    implements _$$GateEntryItemImplCopyWith<$Res> {
  __$$GateEntryItemImplCopyWithImpl(
      _$GateEntryItemImpl _value, $Res Function(_$GateEntryItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of GateEntryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? poNumber = null,
    Object? materialCode = null,
    Object? challanQty = null,
    Object? uom = null,
  }) {
    return _then(_$GateEntryItemImpl(
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GateEntryItemImpl implements _GateEntryItem {
  const _$GateEntryItemImpl(
      {this.id,
      required this.poNumber,
      required this.materialCode,
      required this.challanQty,
      required this.uom});

  factory _$GateEntryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$GateEntryItemImplFromJson(json);

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
  String toString() {
    return 'GateEntryItem(id: $id, poNumber: $poNumber, materialCode: $materialCode, challanQty: $challanQty, uom: $uom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GateEntryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.poNumber, poNumber) ||
                other.poNumber == poNumber) &&
            (identical(other.materialCode, materialCode) ||
                other.materialCode == materialCode) &&
            (identical(other.challanQty, challanQty) ||
                other.challanQty == challanQty) &&
            (identical(other.uom, uom) || other.uom == uom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, poNumber, materialCode, challanQty, uom);

  /// Create a copy of GateEntryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GateEntryItemImplCopyWith<_$GateEntryItemImpl> get copyWith =>
      __$$GateEntryItemImplCopyWithImpl<_$GateEntryItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GateEntryItemImplToJson(
      this,
    );
  }
}

abstract class _GateEntryItem implements GateEntryItem {
  const factory _GateEntryItem(
      {final String? id,
      required final String poNumber,
      required final String materialCode,
      required final int challanQty,
      required final String uom}) = _$GateEntryItemImpl;

  factory _GateEntryItem.fromJson(Map<String, dynamic> json) =
      _$GateEntryItemImpl.fromJson;

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

  /// Create a copy of GateEntryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GateEntryItemImplCopyWith<_$GateEntryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
