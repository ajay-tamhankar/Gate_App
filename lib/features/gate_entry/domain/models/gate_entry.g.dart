// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gate_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GateEntryImpl _$$GateEntryImplFromJson(Map<String, dynamic> json) =>
    _$GateEntryImpl(
      id: json['id'] as String,
      gateEntryNo: json['gateEntryNo'] as String?,
      gateMovement: $enumDecode(_$GateMovementEnumMap, json['gateMovement']),
      challanNo: json['challanNo'] as String,
      transporterName: json['transporterName'] as String,
      vehicleNo: json['vehicleNo'] as String,
      vendorName: json['vendorName'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => GateEntryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? 'Pending',
      gateTimestamp: json['gateTimestamp'] == null
          ? null
          : DateTime.parse(json['gateTimestamp'] as String),
      createdBy: json['createdBy'] as String?,
    );

Map<String, dynamic> _$$GateEntryImplToJson(_$GateEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'gateEntryNo': instance.gateEntryNo,
      'gateMovement': _$GateMovementEnumMap[instance.gateMovement]!,
      'challanNo': instance.challanNo,
      'transporterName': instance.transporterName,
      'vehicleNo': instance.vehicleNo,
      'vendorName': instance.vendorName,
      'items': instance.items,
      'status': instance.status,
      'gateTimestamp': instance.gateTimestamp?.toIso8601String(),
      'createdBy': instance.createdBy,
    };

const _$GateMovementEnumMap = {
  GateMovement.inMovement: 'inMovement',
  GateMovement.outMovement: 'outMovement',
};
