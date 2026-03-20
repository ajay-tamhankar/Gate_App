// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gate_entry_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GateEntryItemImpl _$$GateEntryItemImplFromJson(Map<String, dynamic> json) =>
    _$GateEntryItemImpl(
      id: json['id'] as String?,
      poNumber: json['poNumber'] as String,
      materialCode: json['materialCode'] as String,
      challanQty: (json['challanQty'] as num).toInt(),
      uom: json['uom'] as String,
    );

Map<String, dynamic> _$$GateEntryItemImplToJson(_$GateEntryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'poNumber': instance.poNumber,
      'materialCode': instance.materialCode,
      'challanQty': instance.challanQty,
      'uom': instance.uom,
    };
