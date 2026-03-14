import 'package:freezed_annotation/freezed_annotation.dart';

part 'gate_entry.freezed.dart';
part 'gate_entry.g.dart';

@freezed
class GateEntry with _$GateEntry {
  const factory GateEntry({
    required String id,
    required String challanNumber,
    required String vendorName,
    required String vehicleNumber,
    required String poNumber,
    required DateTime entryTime,
    required String status,
    required String gateDirection,
    required String materialCode,
    required double quantity,
    required String transporterName,
    String? createdBy,
    String? attachmentFileName, // Mocking the attachment
  }) = _GateEntry;

  factory GateEntry.fromJson(Map<String, dynamic> json) =>
      _$GateEntryFromJson(json);
}
