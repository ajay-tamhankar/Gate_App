class GateEntrySummary {
  const GateEntrySummary({
    this.total = 0,
    this.gateIn = 0,
    this.gateOut = 0,
    this.today = 0,
    this.yesterday = 0,
    this.thisWeek = 0,
    this.thisMonth = 0,
  });

  final int total;
  final int gateIn;
  final int gateOut;
  final int today;
  final int yesterday;
  final int thisWeek;
  final int thisMonth;

  factory GateEntrySummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    return GateEntrySummary(
      total: parseInt(json['total']),
      gateIn: parseInt(json['gateIn']),
      gateOut: parseInt(json['gateOut']),
      today: parseInt(json['today']),
      yesterday: parseInt(json['yesterday']),
      thisWeek: parseInt(json['thisWeek']),
      thisMonth: parseInt(json['thisMonth']),
    );
  }
}
