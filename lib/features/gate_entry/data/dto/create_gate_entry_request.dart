import 'package:freezed_annotation/freezed_annotation.dart';

import 'gate_entry_item_response.dart';

part 'create_gate_entry_request.freezed.dart';
part 'create_gate_entry_request.g.dart';

@freezed
class CreateGateEntryRequest with _$CreateGateEntryRequest {
  const factory CreateGateEntryRequest({
    required String challanNo,
    required String vendorName,
    required String vehicleNo,
    required String transporterName,
    required String gateMovement,
    required List<GateEntryItemResponse> items,
  }) = _CreateGateEntryRequest;

  factory CreateGateEntryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGateEntryRequestFromJson(json);
}
