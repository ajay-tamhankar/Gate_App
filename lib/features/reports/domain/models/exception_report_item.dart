class ExceptionReportItem {
  /// Internal identifiers — kept for navigation/debugging but never shown to
  /// the user. Reports display the human-readable [gateEntryNo] instead.
  final String id;
  final String gateEntryId;

  /// Human-readable gate entry number (e.g. GE-2026-000123) shown in reports.
  final String gateEntryNo;
  final String poNumber;
  final String status;
  final String description;
  final DateTime createdAt;

  /// Gate-entry context joined onto the exception so the report is actionable
  /// without cross-referencing the gate register.
  final String invoiceNo;
  final String partNo;
  final int qty;
  final String vendorName;
  final String vendorCode;

  ExceptionReportItem({
    required this.id,
    required this.gateEntryId,
    required this.gateEntryNo,
    required this.poNumber,
    required this.status,
    required this.description,
    required this.createdAt,
    this.invoiceNo = '',
    this.partNo = '',
    this.qty = 0,
    this.vendorName = '',
    this.vendorCode = '',
  });
}
