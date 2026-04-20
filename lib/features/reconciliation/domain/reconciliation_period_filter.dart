enum ReconciliationPeriodFilter {
  all,
  today,
  yesterday,
  thisWeek,
  thisMonth,
}

extension ReconciliationPeriodFilterX on ReconciliationPeriodFilter {
  String get apiValue => switch (this) {
        ReconciliationPeriodFilter.all => 'all',
        ReconciliationPeriodFilter.today => 'today',
        ReconciliationPeriodFilter.yesterday => 'yesterday',
        ReconciliationPeriodFilter.thisWeek => 'this_week',
        ReconciliationPeriodFilter.thisMonth => 'this_month',
      };

  String get label => switch (this) {
        ReconciliationPeriodFilter.all => 'All',
        ReconciliationPeriodFilter.today => 'Today',
        ReconciliationPeriodFilter.yesterday => 'Yesterday',
        ReconciliationPeriodFilter.thisWeek => 'This Week',
        ReconciliationPeriodFilter.thisMonth => 'This Month',
      };

  String get subtitle => switch (this) {
        ReconciliationPeriodFilter.all => 'all reconciliations',
        ReconciliationPeriodFilter.today => "Today's reconciliations",
        ReconciliationPeriodFilter.yesterday => "Yesterday's reconciliations",
        ReconciliationPeriodFilter.thisWeek => 'Current week reconciliations',
        ReconciliationPeriodFilter.thisMonth => 'Current month reconciliations',
      };
}
