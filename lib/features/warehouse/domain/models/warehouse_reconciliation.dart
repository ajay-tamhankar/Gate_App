class WarehouseReconciliationRecord {
  final String id;
  final String gateEntryId;
  final String gateEntryNo;
  final String challanNo;
  final String status;
  final String statusLabel;
  final String matchedGrnNumber;
  final num qtyVariance;
  final String reasonCode;
  final String displayReason;
  final DateTime? date;
  final String reconciledBy;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String resolvedBy;
  final String resolutionNotes;

  // Legacy/compat fields retained for existing UI call sites.
  final String vendorName;
  final String poNumber;
  final num expectedQty;
  final num receivedQty;
  final num acceptedQty;
  final num rejectedQty;
  final num differenceQty;
  final String remarks;
  final String approvedBy;
  final String closedBy;

  const WarehouseReconciliationRecord({
    required this.id,
    required this.gateEntryId,
    required this.gateEntryNo,
    required this.challanNo,
    required this.status,
    required this.statusLabel,
    required this.matchedGrnNumber,
    required this.qtyVariance,
    required this.reasonCode,
    required this.displayReason,
    required this.date,
    required this.reconciledBy,
    required this.isResolved,
    required this.resolvedAt,
    required this.resolvedBy,
    required this.resolutionNotes,
    required this.vendorName,
    required this.poNumber,
    required this.expectedQty,
    required this.receivedQty,
    required this.acceptedQty,
    required this.rejectedQty,
    required this.differenceQty,
    required this.remarks,
    required this.approvedBy,
    required this.closedBy,
  });

  factory WarehouseReconciliationRecord.fromJson(Map<String, dynamic> json) {
    final statusCode = (json['status'] ?? '').toString();
    final statusLabel = (json['statusLabel'] ?? '').toString();

    final qtyVariance = _readNum(json['qtyVariance']);
    final matchedGrn = (json['matchedGrnNumber'] ?? '').toString();
    final displayReason = (json['displayReason'] ?? json['reasonCode'] ?? '').toString();

    return WarehouseReconciliationRecord(
      id: (json['id'] ?? '').toString(),
      gateEntryId: (json['gateEntryId'] ?? json['gate_entry_id'] ?? '').toString(),
      gateEntryNo: (json['gateEntryNo'] ?? json['gate_entry_no'] ?? '').toString(),
      challanNo: (json['challanNo'] ??
              json['challan_no'] ??
              json['challanNumber'] ??
              json['challan_number'] ??
              '')
          .toString(),
      status: statusCode,
      statusLabel: statusLabel,
      matchedGrnNumber: matchedGrn,
      qtyVariance: qtyVariance,
      reasonCode: (json['reasonCode'] ?? '').toString(),
      displayReason: displayReason,
      date: _readDate(json['reconciledAt'] ?? json['createdAt'] ?? json['date']),
      reconciledBy: (json['reconciledBy'] ?? '').toString(),
      isResolved: (json['isResolved'] ?? json['is_resolved'] ?? false) == true,
      resolvedAt: _readDate(json['resolvedAt']),
      resolvedBy: (json['resolvedBy'] ?? '').toString(),
      resolutionNotes: (json['resolutionNotes'] ?? '').toString(),
      vendorName: (json['vendorName'] ?? json['vendor_name'] ?? '').toString(),
      poNumber: matchedGrn,
      expectedQty: _readNum(json['expectedQty']),
      receivedQty: _readNum(json['receivedQty']),
      acceptedQty: _readNum(json['acceptedQty']),
      rejectedQty: _readNum(json['rejectedQty']),
      differenceQty: qtyVariance,
      remarks: displayReason,
      approvedBy: (json['approvedBy'] ?? '').toString(),
      closedBy: (json['closedBy'] ?? '').toString(),
    );
  }

  String get normalizedStatus => status.trim().toLowerCase();

  String get displayStatus {
    if (statusLabel.trim().isNotEmpty) return statusLabel.trim();
    return _humanize(status);
  }

  bool get isMatched => normalizedStatus == 'matched';

  bool get isPending =>
      normalizedStatus == 'pending_grn' ||
      normalizedStatus == 'grn_not_posted' ||
      normalizedStatus.contains('pending');

  bool get isException =>
      !isMatched &&
      (normalizedStatus == 'quantity_mismatch' ||
          normalizedStatus == 'duplicate_grn' ||
          normalizedStatus == 'wrong_po_material' ||
          normalizedStatus == 'grn_not_posted' ||
          normalizedStatus == 'pending_grn' ||
          normalizedStatus.contains('exception') ||
          normalizedStatus.contains('mismatch'));

  bool get isApproved => normalizedStatus.contains('approved');
  bool get isClosed => normalizedStatus.contains('closed');
  bool get isActive => !isClosed;

  static num _readNum(dynamic value) {
    if (value is num) return value;
    if (value == null) return 0;
    return num.tryParse(value.toString()) ?? 0;
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static String _humanize(String value) {
    if (value.trim().isEmpty) return 'Unknown';
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class WarehouseReconciliationSummary {
  final int matched;
  final int pending;
  final int exception;

  const WarehouseReconciliationSummary({
    required this.matched,
    required this.pending,
    required this.exception,
  });
}

class WarehouseManagerDashboardSummary {
  final int pendingApproval;
  final int exceptions;
  final int approvedToday;

  const WarehouseManagerDashboardSummary({
    required this.pendingApproval,
    required this.exceptions,
    required this.approvedToday,
  });
}

class WarehouseReconciliationActionRequest {
  final String actorKey;
  final String actorId;
  final String remarks;

  const WarehouseReconciliationActionRequest({
    required this.actorKey,
    required this.actorId,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      actorKey: actorId,
      'remarks': remarks,
    };
  }
}
