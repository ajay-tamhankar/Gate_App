import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_gate_entry_request.freezed.dart';
part 'create_gate_entry_request.g.dart';

@freezed
class CreateGateEntryRequest with _$CreateGateEntryRequest {
  const factory CreateGateEntryRequest({
    required String challanNumber,
    required String vendorName,
    required String vehicleNumber,
    required String poNumber,
    required String gateDirection,
    required String materialCode,
    required double quantity,
    required String transporterName,
    String? attachmentPath,
  }) = _CreateGateEntryRequest;

  factory CreateGateEntryRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGateEntryRequestFromJson(json);
}
