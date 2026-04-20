class GateEntryQuery {
  const GateEntryQuery({
    this.sortBy,
    this.sortOrder,
    this.status,
    this.challan,
    this.vendor,
    this.po,
    this.q,
    this.startDate,
    this.endDate,
    this.dateFrom,
    this.dateTo,
    this.period,
    this.today,
    this.yesterday,
    this.thisWeek,
    this.thisMonth,
  });

  final String? sortBy;
  final String? sortOrder;
  final String? status;
  final String? challan;
  final String? vendor;
  final String? po;
  final String? q;
  final String? startDate;
  final String? endDate;
  final String? dateFrom;
  final String? dateTo;
  final String? period;
  final bool? today;
  final bool? yesterday;
  final bool? thisWeek;
  final bool? thisMonth;

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    void add(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      params[key] = value;
    }

    add('sortBy', sortBy);
    add('sortOrder', sortOrder);
    add('status', status);
    add('challan', challan);
    add('vendor', vendor);
    add('po', po);
    add('q', q);
    add('startDate', startDate);
    add('endDate', endDate);
    add('dateFrom', dateFrom);
    add('dateTo', dateTo);
    add('period', period);
    add('today', today);
    add('yesterday', yesterday);
    add('thisWeek', thisWeek);
    add('thisMonth', thisMonth);

    return params;
  }
}
