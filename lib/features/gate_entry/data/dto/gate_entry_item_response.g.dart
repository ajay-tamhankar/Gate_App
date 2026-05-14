// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gate_entry_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GateEntryItemResponse _$GateEntryItemResponseFromJson(
        Map<String, dynamic> json) =>
    GateEntryItemResponse(
      id: json['id'] as String?,
      poNumber: json['poNumber'] as String,
      materialCode: json['materialCode'] as String,
      challanQty: (json['challanQty'] as num).toInt(),
      uom: json['uom'] as String,
      challanNo: json['challanNo'] as String?,
    );

Map<String, dynamic> _$GateEntryItemResponseToJson(
        GateEntryItemResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'poNumber': instance.poNumber,
      'materialCode': instance.materialCode,
      'challanQty': instance.challanQty,
      'uom': instance.uom,
      'challanNo': instance.challanNo,
    };
