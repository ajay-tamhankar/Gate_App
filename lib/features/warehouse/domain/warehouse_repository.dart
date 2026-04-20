import 'models/warehouse_gate_entry.dart';
import 'models/warehouse_grn.dart';
import 'models/warehouse_reconciliation.dart';
import '../../reconciliation/domain/reconciliation_period_filter.dart';

abstract class WarehouseRepository {
  Future<List<WarehouseGateEntrySummary>> getGateEntries();
  Future<WarehouseGateEntryDetail> getGateEntryDetail(String id);
  Future<WarehouseGateEntryDetail> verifyGateEntry(
    String id,
    WarehouseGateEntryVerificationRequest request,
  );
  Future<void> approveGateEntry(String id);
  Future<void> closeGateEntry(String id);
  Future<String?> getAttachmentUrl(String id, String attachmentId);
  Future<void> createGrn(WarehouseGrnRequest request);
  Future<List<WarehouseReconciliationRecord>> getReconciliations({
    DateTime? dateFrom,
    DateTime? dateTo,
    ReconciliationPeriodFilter? filter,
  });
  Future<void> approveReconciliation(
    String id,
    WarehouseReconciliationActionRequest request,
  );
  Future<void> closeReconciliation(
    String id,
    WarehouseReconciliationActionRequest request,
  );
}
