import 'package:freezed_annotation/freezed_annotation.dart';

part 'gate_entry_item_response.freezed.dart';
part 'gate_entry_item_response.g.dart';

@freezed
class GateEntryItemResponse with _$GateEntryItemResponse {
  const factory GateEntryItemResponse({
    String? id,
    required String poNumber,
    required String materialCode,
    required int challanQty,
    required String uom,
  }) = _GateEntryItemResponse;

  factory GateEntryItemResponse.fromJson(Map<String, dynamic> json) =>
      _$GateEntryItemResponseFromJson(json);
}
