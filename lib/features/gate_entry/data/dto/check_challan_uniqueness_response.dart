class CheckChallanUniquenessResponse {
  final bool success;
  final String message;
  final ChallanUniquenessData? data;
  final String? error;

  CheckChallanUniquenessResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory CheckChallanUniquenessResponse.fromJson(Map<String, dynamic> json) {
    return CheckChallanUniquenessResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? ChallanUniquenessData.fromJson(json['data']) : null,
      error: json['error'] as String?,
    );
  }
}

class ChallanUniquenessData {
  final String challanNo;
  final bool isUnique;
  final String? existingGateEntryId;
  final String? existingGateEntryNo;
  final String? existingGateMovement;
  final String? existingVendorCode;

  ChallanUniquenessData({
    required this.challanNo,
    required this.isUnique,
    this.existingGateEntryId,
    this.existingGateEntryNo,
    this.existingGateMovement,
    this.existingVendorCode,
  });

  factory ChallanUniquenessData.fromJson(Map<String, dynamic> json) {
    return ChallanUniquenessData(
      challanNo: json['challanNo'] as String? ?? '',
      isUnique: json['isUnique'] as bool? ?? false,
      existingGateEntryId: json['existingGateEntryId'] as String?,
      existingGateEntryNo: json['existingGateEntryNo'] as String?,
      existingGateMovement: json['existingGateMovement'] as String?,
      existingVendorCode: json['existingVendorCode'] as String?,
    );
  }
}
