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
    String? challanNo,
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
      'challanQty': _readFirstNonZeroInt(
        json,
        const ['challanQty', 'challan_qty', 'quantity', 'qty'],
      ),
      'uom': _readString(
        json,
        const ['uom', 'unit'],
        fallback: 'EA',
      ),
      'challanNo': _readNullableString(
        json,
        const ['challanNo', 'challan_no', 'invoiceNo', 'invoice_no'],
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

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString();
    if (text.isNotEmpty) return text;
  }
  return null;
}

int _readFirstNonZeroInt(
  Map<String, dynamic> json,
  List<String> keys, {
  int fallback = 0,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    int? parsed;
    if (value is int) {
      parsed = value;
    } else if (value is num) {
      parsed = value.toInt();
    } else if (value is String) {
      parsed = int.tryParse(value);
    }
    if (parsed != null && parsed != 0) return parsed;
  }
  return fallback;
}
