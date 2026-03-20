import 'package:freezed_annotation/freezed_annotation.dart';
import 'gate_entry_item.dart';

part 'gate_entry.freezed.dart';
part 'gate_entry.g.dart';

enum GateMovement { inMovement, outMovement }

@freezed
class GateEntry with _$GateEntry {
  const factory GateEntry({
    required String id,
    String? gateEntryNo,
    required GateMovement gateMovement,
    required String challanNo,
    required String transporterName,
    required String vehicleNo,
    required String vendorName,
    required List<GateEntryItem> items,
    @Default('Pending') String status,
    DateTime? gateTimestamp,
    String? createdBy,
  }) = _GateEntry;

  factory GateEntry.fromJson(Map<String, dynamic> json) =>
      _$GateEntryFromJson(json);
}


