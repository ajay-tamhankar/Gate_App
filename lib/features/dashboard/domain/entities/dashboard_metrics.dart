class DashboardMetrics {
  const DashboardMetrics({
    required this.totalGateEntriesOverall,
    required this.totalGateEntriesToday,
    required this.totalGateEntriesYesterday,
    required this.totalGateEntriesThisWeek,
    required this.totalGateEntriesMonth,
    required this.gateInCount,
    required this.gateOutCount,
    this.pendingGateOut = 0,
    this.myCreatedToday = 0,
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

  final int totalGateEntriesOverall;
  final int totalGateEntriesToday;
  final int totalGateEntriesYesterday;
  final int totalGateEntriesThisWeek;
  final int totalGateEntriesMonth;
  final int gateInCount;
  final int gateOutCount;

  /// All-time vehicles still inside (gate_in with no gate_out). From the
  /// security dashboard's `pendingGateOut`.
  final int pendingGateOut;

  /// Entries the current user created today (security dashboard `today.myCreated`).
  final int myCreatedToday;

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
    // The security-dashboard endpoint nests today's counters under `today`
    // (totalEntries / gateIn / gateOut / myCreated) and returns the 7-day
    // series as `weeklyActivity`. Older flat keys are still accepted so this
    // stays backward-compatible with any other summary shape.
    final rawToday = json['today'];
    final today =
        rawToday is Map<String, dynamic> ? rawToday : const <String, dynamic>{};

    int pick(Map<String, dynamic> map, List<String> keys) {
      for (final k in keys) {
        final v = map[k];
        if (v is num) return v.toInt();
      }
      return 0;
    }

    // Prefer the nested `today.*` value; fall back to a flat top-level key.
    int fromTodayOrFlat(String todayKey, List<String> flatKeys) {
      final v = today[todayKey];
      if (v is num) return v.toInt();
      return pick(json, flatKeys);
    }

    final activity = (json['weeklyActivity'] as List<dynamic>?) ??
        (json['recentActivity'] as List<dynamic>?) ??
        const <dynamic>[];

    return DashboardMetrics(
      totalGateEntriesOverall: pick(json, ['totalGateEntriesOverall', 'total']),
      totalGateEntriesToday:
          fromTodayOrFlat('totalEntries', ['totalGateEntriesToday']),
      totalGateEntriesYesterday:
          pick(json, ['totalGateEntriesYesterday', 'yesterday']),
      totalGateEntriesThisWeek:
          pick(json, ['totalGateEntriesThisWeek', 'thisWeek']),
      totalGateEntriesMonth: pick(json, ['totalGateEntriesMonth']),
      gateInCount: fromTodayOrFlat('gateIn', ['gateInCount']),
      gateOutCount: fromTodayOrFlat('gateOut', ['gateOutCount']),
      pendingGateOut: pick(json, ['pendingGateOut']),
      myCreatedToday: fromTodayOrFlat('myCreated', ['myCreatedToday']),
      totalGrnPosted: pick(json, ['totalGrnPosted']),
      pendingGrnCount: pick(json, ['pendingGrnCount']),
      quantityMismatchCases: pick(json, ['quantityMismatchCases']),
      duplicateGrnCases: pick(json, ['duplicateGrnCases']),
      gateTat: (json['gateTat'] as num?)?.toDouble() ?? 0,
      dockTat: (json['dockTat'] as num?)?.toDouble() ?? 0,
      pendingGrnAging0To1: pick(json, ['pendingGrnAging0To1']),
      pendingGrnAging2To3: pick(json, ['pendingGrnAging2To3']),
      pendingGrnAgingMoreThan3: pick(json, ['pendingGrnAgingMoreThan3']),
      recentActivity: activity
          .whereType<Map<String, dynamic>>()
          .map(DailyActivity.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalGateEntriesOverall': totalGateEntriesOverall,
      'totalGateEntriesToday': totalGateEntriesToday,
      'totalGateEntriesYesterday': totalGateEntriesYesterday,
      'totalGateEntriesThisWeek': totalGateEntriesThisWeek,
      'totalGateEntriesMonth': totalGateEntriesMonth,
      'gateInCount': gateInCount,
      'gateOutCount': gateOutCount,
      'pendingGateOut': pendingGateOut,
      'myCreatedToday': myCreatedToday,
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
    // `weeklyActivity` uses dayName/count; legacy `recentActivity` uses
    // day/entriesCount.
    final label = json['dayName'] ?? json['day'] ?? '';
    return DailyActivity(
      day: label is String ? label : label.toString(),
      entriesCount: (json['count'] as num?)?.toInt() ??
          (json['entriesCount'] as num?)?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'entriesCount': entriesCount,
    };
  }
}
