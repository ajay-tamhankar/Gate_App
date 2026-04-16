import 'package:freezed_annotation/freezed_annotation.dart';

part 'gate_entry_item_response.freezed.dart';
part 'gate_entry_item_response.g.dart';

@freezed
@JsonSerializable()
class GateEntryItemResponse with _$GateEntryItemResponse {
  const factory GateEntryItemResponse({
    String? id,
    required String poNumber,
    required String materialCode,
    required int challanQty,
    required String uom,
  }) = _GateEntryItemResponse;

  factory GateEntryItemResponse.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{
      ...json,
      'id': json['id']?.toString(),
      'poNumber': _readString(
        json,
        const ['poNumber', 'po_number'],
      ),
      'materialCode': _readString(
        json,
        const ['materialCode', 'partNumber', 'part_number'],
      ),
      'challanQty': _readInt(
        json['challanQty'] ?? json['quantity'],
      ),
      'uom': _readString(
        json,
        const ['uom', 'unit'],
        fallback: 'EA',
      ),
    };

    return _$GateEntryItemResponseFromJson(normalized);
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

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}
