// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reco_exception.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecoExceptionImpl _$$RecoExceptionImplFromJson(Map<String, dynamic> json) =>
    _$RecoExceptionImpl(
      id: json['id'] as String,
      gateEntryId: json['gateEntryId'] as String,
      poNumber: json['poNumber'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] as String?,
      resolvedBy: json['resolvedBy'] as String?,
    );

Map<String, dynamic> _$$RecoExceptionImplToJson(_$RecoExceptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gateEntryId': instance.gateEntryId,
      'poNumber': instance.poNumber,
      'status': instance.status,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'resolvedAt': instance.resolvedAt,
      'resolvedBy': instance.resolvedBy,
    };
