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
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'gateMovement': gateMovement,
      'vendorCode': vendorCode,
      'vendorName': vendorName,
      'invoiceEntries': invoiceEntries.map((entry) => entry.toJson()).toList(),
    };

    if (lrNumber.isNotEmpty) map['lrNumber'] = lrNumber;
    if (driverContactNo.isNotEmpty) map['driverContactNo'] = driverContactNo;
    if (vehicleNo.isNotEmpty) map['vehicleNumber'] = vehicleNo;
    if (transporterName.isNotEmpty) map['transporterName'] = transporterName;

    return map;
  }
}
