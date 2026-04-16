class DashboardMetrics {
  const DashboardMetrics({
    required this.totalGateEntriesToday,
    required this.totalGateEntriesMonth,
    required this.gateInCount,
    required this.gateOutCount,
    required this.totalGrnPosted,
    required this.pendingGrnCount,
    required this.quantityMismatchCases,
    required this.duplicateGrnCases,
    required this.gateTat,
    required this.dockTat,
    required this.pendingGrnAging0To1,
    required this.pendingGrnAging2To3,
    required this.pendingGrnAgingMoreThan3,
    required this.recentActivity,
  });

  final int totalGateEntriesToday;
  final int totalGateEntriesMonth;
  final int gateInCount;
  final int gateOutCount;
  final int totalGrnPosted;
  final int pendingGrnCount;
  final int quantityMismatchCases;
  final int duplicateGrnCases;
  final double gateTat;
  final double dockTat;
  final int pendingGrnAging0To1;
  final int pendingGrnAging2To3;
  final int pendingGrnAgingMoreThan3;
  final List<DailyActivity> recentActivity;

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalGateEntriesToday: (json['totalGateEntriesToday'] as num?)?.toInt() ?? 0,
      totalGateEntriesMonth: (json['totalGateEntriesMonth'] as num?)?.toInt() ?? 0,
      gateInCount: (json['gateInCount'] as num?)?.toInt() ?? 0,
      gateOutCount: (json['gateOutCount'] as num?)?.toInt() ?? 0,
      totalGrnPosted: (json['totalGrnPosted'] as num?)?.toInt() ?? 0,
      pendingGrnCount: (json['pendingGrnCount'] as num?)?.toInt() ?? 0,
      quantityMismatchCases: (json['quantityMismatchCases'] as num?)?.toInt() ?? 0,
      duplicateGrnCases: (json['duplicateGrnCases'] as num?)?.toInt() ?? 0,
      gateTat: (json['gateTat'] as num?)?.toDouble() ?? 0,
      dockTat: (json['dockTat'] as num?)?.toDouble() ?? 0,
      pendingGrnAging0To1: (json['pendingGrnAging0To1'] as num?)?.toInt() ?? 0,
      pendingGrnAging2To3: (json['pendingGrnAging2To3'] as num?)?.toInt() ?? 0,
      pendingGrnAgingMoreThan3: (json['pendingGrnAgingMoreThan3'] as num?)?.toInt() ?? 0,
      recentActivity: ((json['recentActivity'] as List<dynamic>?) ?? const [])
          .map((e) => DailyActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGateEntriesToday': totalGateEntriesToday,
      'totalGateEntriesMonth': totalGateEntriesMonth,
      'gateInCount': gateInCount,
      'gateOutCount': gateOutCount,
      'totalGrnPosted': totalGrnPosted,
      'pendingGrnCount': pendingGrnCount,
      'quantityMismatchCases': quantityMismatchCases,
      'duplicateGrnCases': duplicateGrnCases,
      'gateTat': gateTat,
      'dockTat': dockTat,
      'pendingGrnAging0To1': pendingGrnAging0To1,
      'pendingGrnAging2To3': pendingGrnAging2To3,
      'pendingGrnAgingMoreThan3': pendingGrnAgingMoreThan3,
      'recentActivity': recentActivity.map((e) => e.toJson()).toList(),
    };
  }
}

class DailyActivity {
  const DailyActivity({
    required this.day,
    required this.entriesCount,
  });

  final String day;
  final int entriesCount;

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      day: json['day'] as String? ?? '',
      entriesCount: (json['entriesCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'entriesCount': entriesCount,
    };
  }
}
