import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/report_models.dart';

final mockReportsRepositoryProvider =
    Provider((ref) => MockReportsRepository());

class MockReportsRepository {
  Future<List<GateEntryReportItem>> getGateEntryRegister(
      ReportFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      GateEntryReportItem(
        gateEntryNo: 'GE-20260301-001',
        date: DateTime.now().subtract(const Duration(days: 1)),
        vendor: 'Acme Corp',
        poNumber: 'PO-98765',
        vehicleNo: 'MH-12-AB-3456',
        material: 'Steel Coils',
        status: 'GRN Posted',
      ),
      GateEntryReportItem(
        gateEntryNo: 'GE-20260301-002',
        date: DateTime.now().subtract(const Duration(hours: 4)),
        vendor: 'TechSup Ltd',
        poNumber: 'PO-98766',
        vehicleNo: 'KA-01-XY-9999',
        material: 'Electronics',
        status: 'Pending',
      ),
    ];
  }

  Future<List<GrnReconReportItem>> getGrnReconReport(
      ReportFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      GrnReconReportItem(
        gateEntryNo: 'GE-20260301-001',
        grnNo: 'GRN-10001',
        poNumber: 'PO-98765',
        challanNo: 'CH-8822',
        matchedStatus: 'Matched',
        quantityDiff: 0.0,
      ),
      GrnReconReportItem(
        gateEntryNo: 'GE-20260301-003',
        grnNo: 'GRN-10002',
        poNumber: 'PO-11223',
        challanNo: 'CH-8823',
        matchedStatus: 'Quantity Mismatch',
        quantityDiff: 50.0,
      ),
    ];
  }

  Future<List<PendingGrnReportItem>> getPendingGrnReport(
      ReportFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      PendingGrnReportItem(
        gateEntryNo: 'GE-20260301-002',
        poNumber: 'PO-98766',
        vendor: 'TechSup Ltd',
        material: 'Electronics',
        daysPending: 1,
      ),
      PendingGrnReportItem(
        gateEntryNo: 'GE-20260225-010',
        poNumber: 'PO-55443',
        vendor: 'Global Traders',
        material: 'Raw Plastic',
        daysPending: 4,
      ),
    ];
  }

  Future<List<AuditTrailReportItem>> getAuditTrailReport(
      ReportFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      AuditTrailReportItem(
        date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        user: 'admin',
        action: 'CREATED',
        entity: 'Gate Entry',
        changes: 'Created GE-20260301-001',
      ),
      AuditTrailReportItem(
        date: DateTime.now().subtract(const Duration(hours: 1)),
        user: 'warehouse_mgr',
        action: 'UPDATED',
        entity: 'GRN Status',
        changes: 'GE-20260301-001 set to GRN Posted',
      ),
    ];
  }
}
