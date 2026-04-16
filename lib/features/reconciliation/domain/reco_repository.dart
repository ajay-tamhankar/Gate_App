import 'entities/reco_exception.dart';
import 'entities/reconciliation_item.dart';
import '../../../core/network/pagination_model.dart';

abstract class RecoRepository {
  Future<PaginatedResponse<ReconciliationItem>> getReconciliations({
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int limit = 20,
  });
  Future<List<RecoException>> getExceptions();
  Future<RecoException> getExceptionDetail(String id);
  Future<void> resolveException(String id, String resolutionNotes);
}
