import 'gate_entry_item_response.dart';

class CreateGateEntryInvoiceEntryRequest {
  const CreateGateEntryInvoiceEntryRequest({
    required this.challanNo,
    required this.documentDate,
    required this.poNumber,
    required this.partNumber,
    required this.quantity,
    required this.uom,
  });

  final String challanNo;
  final String documentDate;
  final String poNumber;
  final String partNumber;
  final int quantity;
  final String uom;

  factory CreateGateEntryInvoiceEntryRequest.fromJson(
      Map<String, dynamic> json) {
    return CreateGateEntryInvoiceEntryRequest(
      challanNo: (json['challanNo'] ?? json['challan_no'] ?? '').toString(),
      documentDate:
          (json['documentDate'] ?? json['document_date'] ?? '').toString(),
      poNumber: (json['poNumber'] ?? json['po_number'] ?? '').toString(),
      partNumber: (json['partNumber'] ?? json['part_number'] ?? '').toString(),
      quantity: int.tryParse((json['quantity'] ?? '0').toString()) ?? 0,
      uom: (json['uom'] ?? 'EA').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'challanNo': challanNo,
      'documentDate': documentDate,
      'poNumber': poNumber,
      'partNumber': partNumber,
      'quantity': quantity,
      'uom': uom,
    };
  }
}

class CreateGateEntryRequest {
  const CreateGateEntryRequest({
    required this.gateMovement,
    required this.vendorCode,
    required this.vendorName,
    required this.invoiceEntries,
    this.challanNo = '',
    this.challanNos,
    this.lrNumber = '',
    this.driverContactNo = '',
    this.vehicleNo = '',
    this.transporterName = '',
    this.items = const <GateEntryItemResponse>[],
    this.noOfLineItems,
    this.remark,
  });

  final String gateMovement;
  final String vendorCode;
  final String vendorName;
  final List<CreateGateEntryInvoiceEntryRequest> invoiceEntries;

  // Legacy/compatibility fields retained for local fallback mapping.
  final String challanNo;
  final List<String>? challanNos;
  final String lrNumber;
  final String driverContactNo;
  final String vehicleNo;
  final String transporterName;
  final List<GateEntryItemResponse> items;
  final int? noOfLineItems;
  final String? remark;

  factory CreateGateEntryRequest.fromJson(Map<String, dynamic> json) {
    return CreateGateEntryRequest(
      gateMovement: (json['gateMovement'] ?? '').toString(),
      vendorCode: (json['vendorCode'] ?? '').toString(),
      vendorName: (json['vendorName'] ?? '').toString(),
      invoiceEntries: ((json['invoiceEntries'] ?? json['invoice_entries'])
                  as List<dynamic>? ??
              const [])
          .map((entry) => CreateGateEntryInvoiceEntryRequest.fromJson(
              entry as Map<String, dynamic>))
          .toList(),
      challanNo: (json['challanNo'] ?? '').toString(),
      challanNos: (json['challanNos'] as List<dynamic>?)
          ?.map((entry) => entry.toString())
          .toList(),
      lrNumber: (json['lrNumber'] ?? '').toString(),
      driverContactNo: (json['driverContactNo'] ?? '').toString(),
      vehicleNo: (json['vehicleNo'] ?? '').toString(),
      transporterName: (json['transporterName'] ?? '').toString(),
      items: (json['items'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                GateEntryItemResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      noOfLineItems: _readInt(json, const ['noOfLineItems', 'no_of_line_items']),
      remark: _readNullableString(json, const ['remark', 'remarks']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'gateMovement': gateMovement,
      'vendorCode': vendorCode,
      'vendorName': vendorName,
      'invoiceEntries': invoiceEntries.map((entry) => entry.toJson()).toList(),
    };

    // The backend keeps line quantities on `items[].challanQty`, but this
    // client used to send them ONLY inside `invoiceEntries[].quantity`. When
    // the backend echoed the entry back, `items[].challanQty` came out as 0
    // and the detail view rendered "Qty: 0 NOS". Emit a parallel `items`
    // array here (also with snake_case fallbacks) so quantities land in
    // every field the server or later reads may look at. Legacy callers that
    // already populate `items` win — we don't overwrite their shape.
    final synthesizedItems = items.isNotEmpty
        ? items
            .map((item) => <String, dynamic>{
                  if (item.id != null) 'id': item.id,
                  'materialCode': item.materialCode,
                  'material_code': item.materialCode,
                  'partNumber': item.materialCode,
                  'poNumber': item.poNumber,
                  'po_number': item.poNumber,
                  'challanQty': item.challanQty,
                  'challan_qty': item.challanQty,
                  'quantity': item.challanQty,
                  'qty': item.challanQty,
                  'uom': item.uom,
                  if (item.challanNo != null) 'challanNo': item.challanNo,
                  if (item.challanNo != null) 'challan_no': item.challanNo,
                })
            .toList()
        : invoiceEntries
            .map((entry) => <String, dynamic>{
                  'materialCode': entry.partNumber,
                  'material_code': entry.partNumber,
                  'partNumber': entry.partNumber,
                  'poNumber': entry.poNumber,
                  'po_number': entry.poNumber,
                  'challanQty': entry.quantity,
                  'challan_qty': entry.quantity,
                  'quantity': entry.quantity,
                  'qty': entry.quantity,
                  'uom': entry.uom,
                  'challanNo': entry.challanNo,
                  'challan_no': entry.challanNo,
                })
            .toList();
    if (synthesizedItems.isNotEmpty) {
      map['items'] = synthesizedItems;
    }

    // Top-level challan fields — older endpoints require these alongside the
    // invoiceEntries list. Sending both is harmless when both are accepted.
    if (challanNo.isNotEmpty) {
      map['challanNo'] = challanNo;
      map['challan_no'] = challanNo;
    }
    if (challanNos != null && challanNos!.isNotEmpty) {
      map['challanNos'] = challanNos;
      map['challan_nos'] = challanNos;
    }

    if (lrNumber.isNotEmpty) map['lrNumber'] = lrNumber;
    if (driverContactNo.isNotEmpty) map['driverContactNo'] = driverContactNo;
    if (vehicleNo.isNotEmpty) map['vehicleNumber'] = vehicleNo;
    if (transporterName.isNotEmpty) map['transporterName'] = transporterName;
    if (noOfLineItems != null) map['noOfLineItems'] = noOfLineItems;
    if (remark != null && remark!.isNotEmpty) map['remark'] = remark;

    return map;
  }
}

int? _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    final parsed = int.tryParse(value.toString());
    if (parsed != null) return parsed;
  }
  return null;
}

String? _readNullableString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;
    final text = value.toString();
    if (text.isNotEmpty) return text;
  }
  return null;
}
