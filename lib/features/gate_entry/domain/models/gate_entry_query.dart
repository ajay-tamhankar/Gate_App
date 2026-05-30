const _gateEntryQueryUnset = Object();

class GateEntryQuery {
  const GateEntryQuery({
    this.page,
    this.limit,
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

  final int? page;
  final int? limit;
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

  GateEntryQuery copyWith({
    Object? page = _gateEntryQueryUnset,
    Object? limit = _gateEntryQueryUnset,
    String? sortBy,
    String? sortOrder,
    String? status,
    String? challan,
    String? vendor,
    String? po,
    Object? q = _gateEntryQueryUnset,
    String? startDate,
    String? endDate,
    String? dateFrom,
    String? dateTo,
    Object? period = _gateEntryQueryUnset,
    bool? today,
    bool? yesterday,
    bool? thisWeek,
    bool? thisMonth,
  }) {
    return GateEntryQuery(
      page: identical(page, _gateEntryQueryUnset) ? this.page : page as int?,
      limit: identical(limit, _gateEntryQueryUnset) ? this.limit : limit as int?,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      status: status ?? this.status,
      challan: challan ?? this.challan,
      vendor: vendor ?? this.vendor,
      po: po ?? this.po,
      q: identical(q, _gateEntryQueryUnset) ? this.q : q as String?,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      period: identical(period, _gateEntryQueryUnset)
          ? this.period
          : period as String?,
      today: today ?? this.today,
      yesterday: yesterday ?? this.yesterday,
      thisWeek: thisWeek ?? this.thisWeek,
      thisMonth: thisMonth ?? this.thisMonth,
    );
  }

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    void add(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      params[key] = value;
    }

    add('page', page);
    add('limit', _normalizedLimit(limit));
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

  int? _normalizedLimit(int? value) {
    if (value == null) return null;
    if (value < 1) return 20;
    if (value > 100) return 100;
    return value;
  }
}
