class ReconciliationDashboardSummary {
  final int totalExceptions;
  final int missingTotal;
  final int mismatchTotal;
  final int totalFieldIssues;

  const ReconciliationDashboardSummary({
    required this.totalExceptions,
    required this.missingTotal,
    required this.mismatchTotal,
    required this.totalFieldIssues,
  });

  factory ReconciliationDashboardSummary.fromApiSummary(
    Map<String, dynamic> summaryJson,
    List<ReconciliationDashboardRecord> records,
  ) {
    final gateEntries =
        summaryJson['gateEntries'] as Map<String, dynamic>? ?? const {};
    final byStatus =
        gateEntries['byStatus'] as Map<String, dynamic>? ?? const {};

    final nonMatched = _readInt(gateEntries['nonMatched']);
    if (nonMatched > 0 || byStatus.isNotEmpty) {
      final pendingGrn = _readInt(byStatus['pendingGrn']);
      final grnNotPosted = _readInt(byStatus['grnNotPosted']);
      final qtyMismatch = _readInt(byStatus['quantityMismatch']);
      final duplicateGrn = _readInt(byStatus['duplicateGrn']);
      final wrongPoMaterial = _readInt(byStatus['wrongPoMaterial']);

      return ReconciliationDashboardSummary(
        totalExceptions: nonMatched,
        missingTotal: pendingGrn + grnNotPosted,
        mismatchTotal: qtyMismatch,
        totalFieldIssues: duplicateGrn + wrongPoMaterial,
      );
    }

    final unresolved = records.where((record) => !record.isResolved).toList();
    final missing = unresolved
        .where((r) => r.statusKey == 'pending_grn' || r.statusKey == 'grn_not_posted')
        .length;
    final mismatch = unresolved.where((r) => r.statusKey == 'quantity_mismatch').length;
    final fieldIssues = unresolved
        .where((r) =>
            r.statusKey == 'duplicate_grn' || r.statusKey == 'wrong_po_material')
        .length;

    return ReconciliationDashboardSummary(
      totalExceptions: unresolved.where((r) => !r.isMatched).length,
      missingTotal: missing,
      mismatchTotal: mismatch,
      totalFieldIssues: fieldIssues,
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }
}

class ReconciliationDashboardRecord {
  final String reconciliationId;
  final String gateEntryId;
  final String gateEntryNo;
  final String status;
  final String statusLabel;
  final String matchedGrnNumber;
  final DateTime? reconciledAt;
  final bool isResolved;
  final DateTime? resolvedAt;
  final String resolutionNotes;
  final int lineIssueCount;
  final String reasonCode;
  final String reasonDetail;
  final num qtyVariance;

  const ReconciliationDashboardRecord({
    required this.reconciliationId,
    required this.gateEntryId,
    required this.gateEntryNo,
    required this.status,
    required this.statusLabel,
    required this.matchedGrnNumber,
    required this.reconciledAt,
    required this.isResolved,
    required this.resolvedAt,
    required this.resolutionNotes,
    required this.lineIssueCount,
    required this.reasonCode,
    required this.reasonDetail,
    required this.qtyVariance,
  });

  factory ReconciliationDashboardRecord.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] ?? '').toString();
    final statusKey = status.toLowerCase();
    final qtyVariance = _readNum(json['qtyVariance']);

    return ReconciliationDashboardRecord(
      reconciliationId: (json['id'] ?? json['reconciliationId'] ?? '').toString(),
      gateEntryId: (json['gateEntryId'] ?? '').toString(),
      gateEntryNo: (json['gateEntryNo'] ?? '').toString(),
      status: status,
      statusLabel: (json['statusLabel'] ?? '').toString(),
      matchedGrnNumber: (json['matchedGrnNumber'] ?? '').toString(),
      reconciledAt: _readDate(json['reconciledAt']),
      isResolved: (json['isResolved'] ?? false) == true,
      resolvedAt: _readDate(json['resolvedAt']),
      resolutionNotes: (json['resolutionNotes'] ?? '').toString(),
      lineIssueCount: statusKey == 'matched' ? 0 : 1,
      reasonCode: (json['reasonCode'] ?? '').toString(),
      reasonDetail: (json['displayReason'] ?? '').toString(),
      qtyVariance: qtyVariance,
    );
  }

  String get statusKey => status.trim().toLowerCase();
  bool get isMatched => statusKey == 'matched';

  String get displayStatus {
    if (statusLabel.trim().isNotEmpty) return statusLabel.trim();
    return _humanize(status);
  }

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

/// Global stats returned by GET /reconciliations alongside the filtered list.
/// These counts cover ALL gate entries / reconciliations, not just the filtered view.
class ReconciliationGlobalStats {
  /// Total gate entries ever registered (excluding drafts).
  final int totalGateEntries;

  /// Gate entries fully matched to a SAP GRN.
  final int grnMatched;

  /// Gate entries reconciled but NOT matched (qty mismatch, wrong PO, duplicate, etc.).
  final int grnNotMatched;

  /// Gate entries with no GRN data uploaded yet (pending_grn + never processed).
  final int pendingGrn;

  /// Total gate entries that have a reconciliation record.
  final int totalReconciled;

  const ReconciliationGlobalStats({
    required this.totalGateEntries,
    required this.grnMatched,
    required this.grnNotMatched,
    required this.pendingGrn,
    required this.totalReconciled,
  });

  factory ReconciliationGlobalStats.fromJson(Map<String, dynamic> json) {
    return ReconciliationGlobalStats(
      totalGateEntries: _readInt(json['totalGateEntries']),
      grnMatched: _readInt(json['grnMatched']),
      grnNotMatched: _readInt(json['grnNotMatched']),
      pendingGrn: _readInt(json['pendingGrn']),
      totalReconciled: _readInt(json['totalReconciled']),
    );
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value == null) return 0;
    return int.tryParse(value.toString()) ?? 0;
  }

  /// e.g. "100 entries: 50 matched · 10 issues · 40 pending GRN"
  String get summary =>
      '$totalGateEntries entries: $grnMatched matched · $grnNotMatched issues · $pendingGrn pending GRN';
}

class ReconciliationDashboardData {
  final ReconciliationDashboardSummary summary;
  final List<ReconciliationDashboardRecord> records;
  final ReconciliationGlobalStats? globalStats;

  const ReconciliationDashboardData({
    required this.summary,
    required this.records,
    this.globalStats,
  });

  factory ReconciliationDashboardData.fromApiResponse(Map<String, dynamic> json) {
    final recordsJson = (json['data'] as List?) ?? const [];
    final records = recordsJson
        .whereType<Map<String, dynamic>>()
        .map(ReconciliationDashboardRecord.fromJson)
        .toList();

    final reconciliation =
        json['reconciliation'] as Map<String, dynamic>? ?? const {};
    final summaryJson = reconciliation['summary'] as Map<String, dynamic>? ?? const {};

    ReconciliationGlobalStats? globalStats;
    final statsJson = json['stats'] as Map<String, dynamic>?;
    if (statsJson != null) {
      globalStats = ReconciliationGlobalStats.fromJson(statsJson);
    }

    return ReconciliationDashboardData(
      summary: ReconciliationDashboardSummary.fromApiSummary(summaryJson, records),
      records: records,
      globalStats: globalStats,
    );
  }
}
