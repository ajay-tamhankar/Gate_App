class WarehouseGrnItem {
  final String materialName;
  final num receivedQty;
  final num acceptedQty;
  final num rejectedQty;

  const WarehouseGrnItem({
    required this.materialName,
    required this.receivedQty,
    required this.acceptedQty,
    required this.rejectedQty,
  });

  Map<String, dynamic> toJson() => {
        'materialName': materialName,
        'receivedQty': receivedQty,
        'acceptedQty': acceptedQty,
        'rejectedQty': rejectedQty,
      };
}

class WarehouseGrnRequest {
  final String gateEntryId;
  final List<WarehouseGrnItem> items;
  final String? remarks;

  const WarehouseGrnRequest({
    required this.gateEntryId,
    required this.items,
    this.remarks,
  });

  Map<String, dynamic> toJson() => {
        'gateEntryId': gateEntryId,
        'items': items.map((e) => e.toJson()).toList(),
        'remarks': remarks,
      };
}
