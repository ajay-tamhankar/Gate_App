// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gate_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GateEntryImpl _$$GateEntryImplFromJson(Map<String, dynamic> json) =>
    _$GateEntryImpl(
      id: json['id'] as String,
      challanNumber: json['challanNumber'] as String,
      vendorName: json['vendorName'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      poNumber: json['poNumber'] as String,
      entryTime: DateTime.parse(json['entryTime'] as String),
      status: json['status'] as String,
      gateDirection: json['gateDirection'] as String,
      materialCode: json['materialCode'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      transporterName: json['transporterName'] as String,
      createdBy: json['createdBy'] as String?,
      attachmentFileName: json['attachmentFileName'] as String?,
    );

Map<String, dynamic> _$$GateEntryImplToJson(_$GateEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'challanNumber': instance.challanNumber,
      'vendorName': instance.vendorName,
      'vehicleNumber': instance.vehicleNumber,
      'poNumber': instance.poNumber,
      'entryTime': instance.entryTime.toIso8601String(),
      'status': instance.status,
      'gateDirection': instance.gateDirection,
      'materialCode': instance.materialCode,
      'quantity': instance.quantity,
      'transporterName': instance.transporterName,
      'createdBy': instance.createdBy,
      'attachmentFileName': instance.attachmentFileName,
    };
