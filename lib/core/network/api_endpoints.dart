class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';

  // Gate Entries
  static const String gateEntries = '/gate-entries';
  static String gateEntryVerify(String id) => '/gate-entries/$id/verify';
  static String gateEntryApprove(String id) => '/gate-entries/$id/approve';
  static String gateEntryClose(String id) => '/gate-entries/$id/close';
  static String gateEntryDetails(String id) => '/gate-entries/$id';

  // Reconciliation & Exceptions
  static const String reconciliation = '/reconciliations';
  static const String exceptions = '/reconciliation/exceptions';

  // Reports
  static const String reportGateEntries = '/reports/gate-entries';
  static const String reportReconciliation = '/reports/reconciliation';
  static const String reportExceptions = '/reports/exceptions';

  // SAP / GRN
  static const String grnImport = '/sap/grns/import';

  // Users
  static const String users = '/users';
  static String userDetails(String id) => '/users/$id';
}
