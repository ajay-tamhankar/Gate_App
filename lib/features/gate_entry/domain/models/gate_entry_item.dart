import 'package:freezed_annotation/freezed_annotation.dart';

part 'gate_entry_item.freezed.dart';
part 'gate_entry_item.g.dart';

@freezed
class GateEntryItem with _$GateEntryItem {
  const factory GateEntryItem({
    String? id,
    required String poNumber,
    required String materialCode,
    required int challanQty,
    required String uom,
  }) = _GateEntryItem;

  factory GateEntryItem.fromJson(Map<String, dynamic> json) =>
      _$GateEntryItemFromJson(json);
}
