class WarehouseReconciliationRecord {
  final String id;
  final String gateEntryId;
  final String gateEntryNo;
  final String vendorName;
  final String poNumber;
  final String status;
  final DateTime? date;
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
    required this.vendorName,
    required this.poNumber,
    required this.status,
    required this.date,
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
    final dateRaw = json['date'] ?? json['postingDate'] ?? json['createdAt'];
    DateTime? parsed;
    if (dateRaw != null) {
      parsed = DateTime.tryParse(dateRaw.toString());
    }

    final grn = json['grn'] as Map<String, dynamic>? ?? const {};
    final sap = json['sap'] as Map<String, dynamic>? ?? const {};

    num readNum(List<dynamic> values) {
      for (final value in values) {
        if (value is num) return value;
        if (value != null) {
          final parsed = num.tryParse(value.toString());
          if (parsed != null) return parsed;
        }
      }
      return 0;
    }

    final receivedQty = readNum([
      json['receivedQty'],
      json['grnReceivedQty'],
      grn['receivedQty'],
      grn['totalReceivedQty'],
    ]);
    final expectedQty = readNum([
      json['expectedQty'],
      json['sapExpectedQty'],
      sap['expectedQty'],
      sap['quantity'],
    ]);

    return WarehouseReconciliationRecord(
      id: (json['id'] ?? '').toString(),
      gateEntryId: (json['gateEntryId'] ?? json['gate_entry_id'] ?? '').toString(),
      gateEntryNo: (json['gateEntryNo'] ?? json['gate_entry_no'] ?? '').toString(),
      vendorName: (json['vendorName'] ?? json['vendor_name'] ?? '').toString(),
      poNumber: (json['poNumber'] ?? json['po_number'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      date: parsed,
      expectedQty: expectedQty,
      receivedQty: receivedQty,
      acceptedQty: readNum([
        json['acceptedQty'],
        json['grnAcceptedQty'],
        grn['acceptedQty'],
      ]),
      rejectedQty: readNum([
        json['rejectedQty'],
        json['grnRejectedQty'],
        grn['rejectedQty'],
      ]),
      differenceQty: readNum([
        json['differenceQty'],
        json['difference'],
        expectedQty - receivedQty,
      ]),
      remarks: (json['remarks'] ?? json['remark'] ?? '').toString(),
      approvedBy: (json['approvedBy'] ?? '').toString(),
      closedBy: (json['closedBy'] ?? '').toString(),
    );
  }

  String get normalizedStatus => status.toLowerCase();

  bool get isMatched => normalizedStatus.contains('match');
  bool get isPending => normalizedStatus.contains('pending');
  bool get isException =>
      normalizedStatus.contains('exception') || normalizedStatus.contains('mismatch');
  bool get isApproved => normalizedStatus.contains('approved');
  bool get isClosed => normalizedStatus.contains('closed');
  bool get isActive => !isClosed;
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