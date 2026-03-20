import 'package:freezed_annotation/freezed_annotation.dart';
import 'gate_entry_item_response.dart';

part 'gate_entry_response.freezed.dart';
part 'gate_entry_response.g.dart';

@freezed
class GateEntryResponse with _$GateEntryResponse {
  const factory GateEntryResponse({
    required String id,
    required String gateEntryNo,
    String? gateTimestamp,
    required String gateMovement,
    required String challanNo,
    required String transporterName,
    required String vehicleNo,
    required String vendorName,
    String? status,
    required List<GateEntryItemResponse> items,
  }) = _GateEntryResponse;

  factory GateEntryResponse.fromJson(Map<String, dynamic> json) =>
      _$GateEntryResponseFromJson(json);
}
