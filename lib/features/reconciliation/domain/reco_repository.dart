import 'entities/reco_exception.dart';
import 'entities/reconciliation_item.dart';
import 'reconciliation_period_filter.dart';

abstract class RecoRepository {
  Future<List<ReconciliationItem>> getReconciliations({
    DateTime? dateFrom,
    DateTime? dateTo,
    ReconciliationPeriodFilter? filter,
  });
  Future<List<RecoException>> getExceptions();
  Future<RecoException> getExceptionDetail(String id);
  Future<void> resolveException(String id, String resolutionNotes);
}
