// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gate_entry_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GateEntryItemResponseImpl _$$GateEntryItemResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GateEntryItemResponseImpl(
      id: json['id'] as String?,
      poNumber: json['poNumber'] as String,
      materialCode: json['materialCode'] as String,
      challanQty: (json['challanQty'] as num).toInt(),
      uom: json['uom'] as String,
    );

Map<String, dynamic> _$$GateEntryItemResponseImplToJson(
        _$GateEntryItemResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'poNumber': instance.poNumber,
      'materialCode': instance.materialCode,
      'challanQty': instance.challanQty,
      'uom': instance.uom,
    };
