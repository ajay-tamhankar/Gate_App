// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'resolve_exception_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ResolveExceptionRequest _$ResolveExceptionRequestFromJson(
    Map<String, dynamic> json) {
  return _ResolveExceptionRequest.fromJson(json);
}

/// @nodoc
mixin _$ResolveExceptionRequest {
  String get resolutionNotes => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this ResolveExceptionRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResolveExceptionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResolveExceptionRequestCopyWith<ResolveExceptionRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResolveExceptionRequestCopyWith<$Res> {
  factory $ResolveExceptionRequestCopyWith(ResolveExceptionRequest value,
          $Res Function(ResolveExceptionRequest) then) =
      _$ResolveExceptionRequestCopyWithImpl<$Res, ResolveExceptionRequest>;
  @useResult
  $Res call({String resolutionNotes, String status});
}

/// @nodoc
class _$ResolveExceptionRequestCopyWithImpl<$Res,
        $Val extends ResolveExceptionRequest>
    implements $ResolveExceptionRequestCopyWith<$Res> {
  _$ResolveExceptionRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResolveExceptionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resolutionNotes = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      resolutionNotes: null == resolutionNotes
          ? _value.resolutionNotes
          : resolutionNotes // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResolveExceptionRequestImplCopyWith<$Res>
    implements $ResolveExceptionRequestCopyWith<$Res> {
  factory _$$ResolveExceptionRequestImplCopyWith(
          _$ResolveExceptionRequestImpl value,
          $Res Function(_$ResolveExceptionRequestImpl) then) =
      __$$ResolveExceptionRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String resolutionNotes, String status});
}

/// @nodoc
class __$$ResolveExceptionRequestImplCopyWithImpl<$Res>
    extends _$ResolveExceptionRequestCopyWithImpl<$Res,
        _$ResolveExceptionRequestImpl>
    implements _$$ResolveExceptionRequestImplCopyWith<$Res> {
  __$$ResolveExceptionRequestImplCopyWithImpl(
      _$ResolveExceptionRequestImpl _value,
      $Res Function(_$ResolveExceptionRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResolveExceptionRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? resolutionNotes = null,
    Object? status = null,
  }) {
    return _then(_$ResolveExceptionRequestImpl(
      resolutionNotes: null == resolutionNotes
          ? _value.resolutionNotes
          : resolutionNotes // ignore: cast_nullable_to_non_nullable
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
class _$ResolveExceptionRequestImpl implements _ResolveExceptionRequest {
  const _$ResolveExceptionRequestImpl(
      {required this.resolutionNotes, required this.status});

  factory _$ResolveExceptionRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResolveExceptionRequestImplFromJson(json);

  @override
  final String resolutionNotes;
  @override
  final String status;

  @override
  String toString() {
    return 'ResolveExceptionRequest(resolutionNotes: $resolutionNotes, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResolveExceptionRequestImpl &&
            (identical(other.resolutionNotes, resolutionNotes) ||
                other.resolutionNotes == resolutionNotes) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, resolutionNotes, status);

  /// Create a copy of ResolveExceptionRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResolveExceptionRequestImplCopyWith<_$ResolveExceptionRequestImpl>
      get copyWith => __$$ResolveExceptionRequestImplCopyWithImpl<
          _$ResolveExceptionRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResolveExceptionRequestImplToJson(
      this,
    );
  }
}

abstract class _ResolveExceptionRequest implements ResolveExceptionRequest {
  const factory _ResolveExceptionRequest(
      {required final String resolutionNotes,
      required final String status}) = _$ResolveExceptionRequestImpl;

  factory _ResolveExceptionRequest.fromJson(Map<String, dynamic> json) =
      _$ResolveExceptionRequestImpl.fromJson;

  @override
  String get resolutionNotes;
  @override
  String get status;

  /// Create a copy of ResolveExceptionRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResolveExceptionRequestImplCopyWith<_$ResolveExceptionRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
