import 'package:freezed_annotation/freezed_annotation.dart';
import 'gate_entry_item_response.dart';

part 'gate_entry_response.freezed.dart';
part 'gate_entry_response.g.dart';

@freezed
@JsonSerializable()
class GateEntryResponse with _$GateEntryResponse {
  const factory GateEntryResponse({
    required String id,
    required String gateEntryNo,
    String? gateTimestamp,
    required String gateMovement,
    required String challanNo,
    @Default('') String lrNumber,
    required String transporterName,
    required String vehicleNo,
    @Default('') String driverContactNo,
    @Default('') String vendorCode,
    required String vendorName,
    String? status,
    required List<GateEntryItemResponse> items,
    String? gateOutTimestamp,
    String? gateOutBy,
  }) = _GateEntryResponse;

  factory GateEntryResponse.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{
      ...json,
      'id': _readString(json, const ['id']),
      'gateEntryNo': _readString(
        json,
        const ['gateEntryNo', 'gate_entry_no'],
      ),
      'gateTimestamp': _readNullableString(
        json,
        const ['gateTimestamp', 'entryTime', 'createdAt'],
      ),
      'gateMovement': _readString(
        json,
        const ['gateMovement', 'gateDirection'],
      ),
      'challanNo': _readString(
        json,
        const ['challanNo', 'challanNumber'],
      ),
      'lrNumber': _readString(
        json,
        const ['lrNumber', 'lr_number'],
      ),
      'transporterName': _readString(
        json,
        const ['transporterName'],
      ),
      'vehicleNo': _readString(
        json,
        const ['vehicleNo', 'vehicleNumber'],
      ),
      'driverContactNo': _readString(
        json,
        const ['driverContactNo', 'driver_contact_no'],
      ),
      'vendorCode': _readString(
        json,
        const ['vendorCode', 'vendor_code'],
      ),
      'vendorName': _readString(
        json,
        const ['vendorName', 'vendor_name'],
      ),
      'status': _readNullableString(
        json,
        const ['status', 'statusLabel'],
      ),
      'gateOutTimestamp': _readNullableString(
        json,
        const ['gateOutTimestamp', 'gateOutTime'],
      ),
      'gateOutBy': _readNullableString(
        json,
        const ['gateOutBy'],
      ),
      'items': (json['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(),
    };

    return _$GateEntryResponseFromJson(normalized);
  }
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString();
    if (text.isNotEmpty) return text;
  }
  return fallback;
}

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString();
    if (text.isNotEmpty) return text;
  }
  return null;
}
