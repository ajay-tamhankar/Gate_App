import 'warehouse_attachment.dart';

class WarehouseGateEntryItem {
  final String materialCode;
  final String poNumber;
  final num challanQty;
  final String uom;

  const WarehouseGateEntryItem({
    required this.materialCode,
    required this.poNumber,
    required this.challanQty,
    required this.uom,
  });

  factory WarehouseGateEntryItem.fromJson(Map<String, dynamic> json) {
    return WarehouseGateEntryItem(
      materialCode:
          (json['materialCode'] ?? json['material_code'] ?? '').toString(),
      poNumber: (json['poNumber'] ?? json['po_number'] ?? '').toString(),
      challanQty: (json['challanQty'] ?? json['quantity'] ?? 0) as num,
      uom: (json['uom'] ?? json['unit'] ?? '').toString(),
    );
  }
}

class WarehouseGateEntrySummary {
  final String id;
  final String gateEntryNo;
  final String vendorName;
  final String vehicleNo;
  final DateTime? entryTime;
  final String statusLabel;
  final String poNumber;
  final String grnStatus;

  const WarehouseGateEntrySummary({
    required this.id,
    required this.gateEntryNo,
    required this.vendorName,
    required this.vehicleNo,
    required this.entryTime,
    required this.statusLabel,
    required this.poNumber,
    required this.grnStatus,
  });

  factory WarehouseGateEntrySummary.fromJson(Map<String, dynamic> json) {
    final entryTimeRaw =
        json['entryTime'] ?? json['gateTimestamp'] ?? json['createdAt'];
    DateTime? parsed;
    if (entryTimeRaw != null) {
      parsed = DateTime.tryParse(entryTimeRaw.toString());
    }
    return WarehouseGateEntrySummary(
      id: (json['id'] ?? '').toString(),
      gateEntryNo: (json['gateEntryNo'] ?? json['gate_entry_no'] ?? '')
          .toString(),
      vendorName: (json['vendorName'] ?? json['vendor_name'] ?? '').toString(),
      vehicleNo: (json['vehicleNo'] ?? json['vehicleNumber'] ?? '').toString(),
      entryTime: parsed,
      statusLabel:
          (json['statusLabel'] ?? json['status'] ?? 'Pending').toString(),
      poNumber: (json['poNumber'] ?? '').toString(),
      grnStatus:
          (json['grnStatus'] ?? json['grn_status'] ?? 'PENDING').toString(),
    );
  }

  bool get isCompleted => grnStatus.toLowerCase() == 'completed';
  bool get isApproved => _statusContains(statusLabel, 'approved');
  bool get isClosed => _statusContains(statusLabel, 'closed');
  bool get isVerified => _statusContains(statusLabel, 'verified');
}

class WarehouseGateEntryDetail {
  final String id;
  final String gateEntryNo;
  final String vendorName;
  final String vehicleNo;
  final DateTime? entryTime;
  final String gateMovement;
  final String challanNo;
  final String transporterName;
  final String statusLabel;
  final String grnStatus;
  final String poNumber;
  final String remarks;
  final bool isVerified;
  final List<WarehouseGateEntryItem> items;
  final List<WarehouseAttachment> attachments;

  const WarehouseGateEntryDetail({
    required this.id,
    required this.gateEntryNo,
    required this.vendorName,
    required this.vehicleNo,
    required this.entryTime,
    required this.gateMovement,
    required this.challanNo,
    required this.transporterName,
    required this.statusLabel,
    required this.grnStatus,
    required this.poNumber,
    required this.remarks,
    required this.isVerified,
    required this.items,
    required this.attachments,
  });

  factory WarehouseGateEntryDetail.fromJson(Map<String, dynamic> json) {
    final entryTimeRaw =
        json['entryTime'] ?? json['gateTimestamp'] ?? json['createdAt'];
    DateTime? parsed;
    if (entryTimeRaw != null) {
      parsed = DateTime.tryParse(entryTimeRaw.toString());
    }
    final itemsRaw = json['items'] as List? ?? const [];
    final attachmentsRaw = json['attachments'] as List? ?? const [];
    return WarehouseGateEntryDetail(
      id: (json['id'] ?? '').toString(),
      gateEntryNo: (json['gateEntryNo'] ?? '').toString(),
      vendorName: (json['vendorName'] ?? '').toString(),
      vehicleNo: (json['vehicleNo'] ?? json['vehicleNumber'] ?? '').toString(),
      entryTime: parsed,
      gateMovement:
          (json['gateMovement'] ?? json['gateDirection'] ?? '').toString(),
      challanNo: (json['challanNo'] ?? json['challanNumber'] ?? '').toString(),
      transporterName: (json['transporterName'] ?? '').toString(),
      statusLabel:
          (json['statusLabel'] ?? json['status'] ?? 'Pending').toString(),
      grnStatus:
          (json['grnStatus'] ?? json['grn_status'] ?? 'PENDING').toString(),
      poNumber: _resolvePoNumber(json, itemsRaw),
      remarks: (json['remarks'] ?? json['remark'] ?? '').toString(),
      isVerified: _resolveIsVerified(json),
      items: itemsRaw
          .whereType<Map<String, dynamic>>()
          .map(WarehouseGateEntryItem.fromJson)
          .toList(),
      attachments: attachmentsRaw
          .whereType<Map<String, dynamic>>()
          .map(WarehouseAttachment.fromJson)
          .toList(),
    );
  }

  bool get canEdit => grnStatus.toLowerCase() != 'completed';
  bool get canCreateGrn =>
      grnStatus.toLowerCase() != 'completed' && isVerified;
  bool get isApproved => _statusContains(statusLabel, 'approved');
  bool get isClosed => _statusContains(statusLabel, 'closed');

  static String _resolvePoNumber(
    Map<String, dynamic> json,
    List<dynamic> itemsRaw,
  ) {
    final directPo = (json['poNumber'] ?? json['po_number'] ?? '').toString();
    if (directPo.isNotEmpty) return directPo;
    for (final item in itemsRaw.whereType<Map<String, dynamic>>()) {
      final itemPo = (item['poNumber'] ?? item['po_number'] ?? '').toString();
      if (itemPo.isNotEmpty) return itemPo;
    }
    return '';
  }

  static bool _resolveIsVerified(Map<String, dynamic> json) {
    final raw = json['isVerified'] ?? json['is_verified'];
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      final normalized = raw.toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'verified';
    }
    final status =
        (json['statusLabel'] ?? json['status'] ?? '').toString().toLowerCase();
    return status.contains('verified');
  }
}

class WarehouseGateEntryVerificationRequest {
  final String vendorName;
  final String vehicleNo;
  final String poNumber;
  final String remarks;
  final bool isVerified;

  const WarehouseGateEntryVerificationRequest({
    required this.vendorName,
    required this.vehicleNo,
    required this.poNumber,
    required this.remarks,
    this.isVerified = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'vendorName': vendorName,
      'vehicleNo': vehicleNo,
      'poNumber': poNumber,
      'remarks': remarks,
      'isVerified': isVerified,
    };
  }
}

bool _statusContains(String value, String expected) {
  return value.toLowerCase().contains(expected);
}
