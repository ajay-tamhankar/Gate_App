// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_gate_entry_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreateGateEntryRequestImpl _$$CreateGateEntryRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateGateEntryRequestImpl(
      challanNumber: json['challanNumber'] as String,
      vendorName: json['vendorName'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      poNumber: json['poNumber'] as String,
      gateDirection: json['gateDirection'] as String,
      materialCode: json['materialCode'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      transporterName: json['transporterName'] as String,
      attachmentPath: json['attachmentPath'] as String?,
    );

Map<String, dynamic> _$$CreateGateEntryRequestImplToJson(
        _$CreateGateEntryRequestImpl instance) =>
    <String, dynamic>{
      'challanNumber': instance.challanNumber,
      'vendorName': instance.vendorName,
      'vehicleNumber': instance.vehicleNumber,
      'poNumber': instance.poNumber,
      'gateDirection': instance.gateDirection,
      'materialCode': instance.materialCode,
      'quantity': instance.quantity,
      'transporterName': instance.transporterName,
      'attachmentPath': instance.attachmentPath,
    };
