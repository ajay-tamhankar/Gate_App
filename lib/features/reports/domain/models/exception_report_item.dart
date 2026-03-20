class ExceptionReportItem {
  final String id;
  final String gateEntryId;
  final String poNumber;
  final String status;
  final String description;
  final DateTime createdAt;

  ExceptionReportItem({
    required this.id,
    required this.gateEntryId,
    required this.poNumber,
    required this.status,
    required this.description,
    required this.createdAt,
  });
}
