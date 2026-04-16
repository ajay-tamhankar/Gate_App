class ReconciliationItem {
  final String id;
  final String gateEntryId;
  final String gateEntryNo;
  final String status;
  final String statusLabel;
  final String matchedGrnNumber;
  final num qtyVariance;
  final String reasonCode;
  final String displayReason;
  final DateTime? reconciledAt;
  final String reconciledBy;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String resolvedBy;
  final String resolutionNotes;

  ReconciliationItem({
    required this.id,
    required this.gateEntryId,
    required this.gateEntryNo,
    required this.status,
    required this.statusLabel,
    required this.matchedGrnNumber,
    required this.qtyVariance,
    required this.reasonCode,
    required this.displayReason,
    required this.reconciledAt,
    required this.reconciledBy,
    required this.isResolved,
    required this.resolvedAt,
    required this.resolvedBy,
    required this.resolutionNotes,
  });

  factory ReconciliationItem.fromJson(Map<String, dynamic> json) {
    num readNum(dynamic value) {
      if (value is num) return value;
      if (value == null) return 0;
      return num.tryParse(value.toString()) ?? 0;
    }

    DateTime? readDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    final gateEntryId = (json['gateEntryId'] ?? json['gate_entry_id'] ?? '').toString();
    final gateEntryNo =
        (json['gateEntryNo'] ?? json['gate_entry_no'] ?? gateEntryId).toString();
    final status = (json['status'] ?? '').toString();
    final statusLabel = (json['statusLabel'] ?? '').toString();
    final idValue = (json['id'] ??
            json['_id'] ??
            json['reconciliationId'] ??
            json['recoId'] ??
            gateEntryId)
        .toString();
    final isResolved = (json['is_resolved'] ?? json['isResolved'] ?? false) == true;

    return ReconciliationItem(
      id: idValue,
      gateEntryId: gateEntryId,
      gateEntryNo: gateEntryNo,
      status: status,
      statusLabel: statusLabel,
      matchedGrnNumber: (json['matchedGrnNumber'] ?? '').toString(),
      qtyVariance: readNum(json['qtyVariance']),
      reasonCode: (json['reasonCode'] ?? '').toString(),
      displayReason: (json['displayReason'] ?? '').toString(),
      reconciledAt: readDate(json['reconciledAt']),
      reconciledBy: (json['reconciledBy'] ?? '').toString(),
      isResolved: isResolved,
      resolvedAt: readDate(json['resolvedAt']),
      resolvedBy: (json['resolvedBy'] ?? '').toString(),
      resolutionNotes: (json['resolutionNotes'] ?? '').toString(),
    );
  }

  String get normalizedStatus => status.trim().toLowerCase();

  String get displayStatus {
    if (statusLabel.trim().isNotEmpty) return statusLabel.trim();
    return _humanizeStatus(status);
  }

  bool get isMatched => normalizedStatus == 'matched';
  bool get isQuantityMismatch => normalizedStatus == 'quantity_mismatch';

  bool get isException =>
      normalizedStatus == 'quantity_mismatch' ||
      normalizedStatus == 'grn_not_posted' ||
      normalizedStatus == 'duplicate_grn' ||
      normalizedStatus == 'wrong_po_material' ||
      normalizedStatus == 'pending_grn' ||
      normalizedStatus.contains('exception');

  static String _humanizeStatus(String value) {
    if (value.trim().isEmpty) return 'Unknown';
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}
