// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_gate_entry_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateGateEntryRequestImpl _$$CreateGateEntryRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateGateEntryRequestImpl(
      challanNo: json['challanNo'] as String,
      vendorName: json['vendorName'] as String,
      vehicleNo: json['vehicleNo'] as String,
      transporterName: json['transporterName'] as String,
      gateMovement: json['gateMovement'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => GateEntryItemResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$CreateGateEntryRequestImplToJson(
        _$CreateGateEntryRequestImpl instance) =>
    <String, dynamic>{
      'challanNo': instance.challanNo,
      'vendorName': instance.vendorName,
      'vehicleNo': instance.vehicleNo,
      'transporterName': instance.transporterName,
      'gateMovement': instance.gateMovement,
      'items': instance.items,
    };
