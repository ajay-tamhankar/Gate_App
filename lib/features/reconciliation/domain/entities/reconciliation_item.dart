class ReconciliationItem {
  final String id;
  final String gateEntryId;
  final String gateEntryNo;
  final String status;
  final DateTime? date;

  ReconciliationItem({
    required this.id,
    required this.gateEntryId,
    required this.gateEntryNo,
    required this.status,
    required this.date,
  });

  factory ReconciliationItem.fromJson(Map<String, dynamic> json) {
    final gateEntry = json['gateEntry'] as Map<String, dynamic>?;
    final idValue = (json['id'] ??
            json['_id'] ??
            json['reconciliationId'] ??
            json['recoId'] ??
            '')
        .toString();
    final gateEntryId = (json['gateEntryId'] ??
            json['gate_entry_id'] ??
            gateEntry?['id'] ??
            gateEntry?['_id'] ??
            '')
        .toString();
    final gateEntryNo = (json['gateEntryNo'] ??
            json['gate_entry_no'] ??
            gateEntry?['gateEntryNo'] ??
            gateEntry?['gate_entry_no'] ??
            '')
        .toString();
    final status = (json['status'] ??
            json['reconciliationStatus'] ??
            json['recoStatus'] ??
            json['matchStatus'] ??
            '')
        .toString();

    final dateRaw = json['date'] ??
        json['postingDate'] ??
        json['createdAt'] ??
        json['created_at'];
    final parsedDate = DateTime.tryParse(dateRaw?.toString() ?? '');

    return ReconciliationItem(
      id: idValue,
      gateEntryId: gateEntryId,
      gateEntryNo: gateEntryNo,
      status: status,
      date: parsedDate,
    );
  }
}
