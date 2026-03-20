// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gate_entry_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GateEntryResponseImpl _$$GateEntryResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$GateEntryResponseImpl(
      id: json['id'] as String,
      gateEntryNo: json['gateEntryNo'] as String,
      gateTimestamp: json['gateTimestamp'] as String?,
      gateMovement: json['gateMovement'] as String,
      challanNo: json['challanNo'] as String,
      transporterName: json['transporterName'] as String,
      vehicleNo: json['vehicleNo'] as String,
      vendorName: json['vendorName'] as String,
      status: json['status'] as String?,
      items: (json['items'] as List<dynamic>)
          .map((e) => GateEntryItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GateEntryResponseImplToJson(
        _$GateEntryResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gateEntryNo': instance.gateEntryNo,
      'gateTimestamp': instance.gateTimestamp,
      'gateMovement': instance.gateMovement,
      'challanNo': instance.challanNo,
      'transporterName': instance.transporterName,
      'vehicleNo': instance.vehicleNo,
      'vendorName': instance.vendorName,
      'status': instance.status,
      'items': instance.items,
    };
