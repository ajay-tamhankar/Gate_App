import 'package:flutter_test/flutter_test.dart';
import 'package:gate_reco_app/features/gate_entry/data/mock_gate_entry_repository.dart';
import 'package:gate_reco_app/features/reconciliation/data/mock_reco_repository.dart';

void main() {
  group('Workflow Process Tests', () {
    late MockGateEntryRepository gateRepo;
    late MockRecoRepository recoRepo;

    setUp(() {
      gateRepo = MockGateEntryRepository();
      recoRepo = MockRecoRepository();
      recoRepo.clearForTest(); // Ensure clean state
    });

    test('Flow 1: Matched Gate Entry -> Status Closed (Matched)', () async {
      // 1. Vehicle arrives -> Gate Entry created
      final entry = await gateRepo.createGateEntry(
        challanNumber: 'CH-TEST-001',
        vendorName: 'Perfect Vendor',
        vehicleNumber: 'TS-09-XX-1111',
        poNumber: 'PO-TEST-100',
        gateDirection: 'Gate In',
        materialCode: 'MAT-TEST',
        quantity: 100.0,
        transporterName: 'Test Transporter',
      );

      // 2. SAP GRN posted (Set up source of truth)
      recoRepo.setupSapMockForTest('PO-TEST-100', {
        'materialCode': 'MAT-TEST',
        'allowedQty': 100.0,
        'vendor': 'Perfect Vendor',
        'isClosed': false,
      });

      // 3. System auto-reconciles Gate Entry vs GRN
      // Inject entry to simulate picking up from DB
      recoRepo.addGateEntryForTest(entry);

      // Trigger Engine (getExceptions runs it)
      await recoRepo.getExceptions();

      // 4. Verify Matched Status
      final matchRecord = recoRepo.getExceptionByGateEntryId(entry.id);
      expect(matchRecord.status, 'Matched');
    });

    test(
        'Flow 2: Quantity Mismatch -> Exception Generated -> Warehouse Team Updates',
        () async {
      // 1. Vehicle arrives -> Gate Entry created with higher quantity
      final entry = await gateRepo.createGateEntry(
        challanNumber: 'CH-TEST-002',
        vendorName: 'Bad Vendor',
        vehicleNumber: 'TS-09-XX-2222',
        poNumber: 'PO-TEST-200',
        gateDirection: 'Gate In',
        materialCode: 'MAT-BAD',
        quantity: 150.0, // Erroneous extra 50
        transporterName: 'Test Transporter',
      );

      // 2. SAP GRN posted (True source of truth has 100)
      recoRepo.setupSapMockForTest('PO-TEST-200', {
        'materialCode': 'MAT-BAD',
        'allowedQty': 100.0,
        'vendor': 'Bad Vendor',
        'isClosed': false,
      });

      // 3. System auto-reconciles
      recoRepo.addGateEntryForTest(entry);
      await recoRepo.getExceptions();

      // 4. Verify Exception Generated
      final mismatchRecord = recoRepo.getExceptionByGateEntryId(entry.id);
      expect(mismatchRecord.status, 'Quantity Mismatch');

      // 5. Warehouse team investigates & updates/resolves the exception
      await recoRepo.resolveException(mismatchRecord.id,
          'Vendor accidentally shipped 50 extra. Adjusted in SAP.');

      // 6. Verify Resolution
      final resolvedRecord =
          await recoRepo.getExceptionDetail(mismatchRecord.id);
      expect(resolvedRecord.status, 'Resolved');
      expect(resolvedRecord.description,
          contains('Vendor accidentally shipped 50 extra.'));
    });

    test('Flow 3: Duplicate GRN Detected -> Exception Generated', () async {
      // 1. Gate entry
      final entry = await gateRepo.createGateEntry(
        challanNumber: 'CH-TEST-003',
        vendorName: 'Duplicate Vendor',
        vehicleNumber: 'TS-09-XX-3333',
        poNumber: 'PO-TEST-300',
        gateDirection: 'Gate In',
        materialCode: 'MAT-DUP',
        quantity: 50.0,
        transporterName: 'Test Transporter',
      );

      // 2. SAP GRN posted but flagged as Closed
      recoRepo.setupSapMockForTest('PO-TEST-300', {
        'materialCode': 'MAT-DUP',
        'allowedQty': 50.0,
        'vendor': 'Duplicate Vendor',
        'isClosed': true,
      });

      // 3. System auto-reconciles
      recoRepo.addGateEntryForTest(entry);
      await recoRepo.getExceptions();

      // 4. Verify Exception Generated
      final duplicateRecord = recoRepo.getExceptionByGateEntryId(entry.id);
      expect(duplicateRecord.status, 'Duplicate GRN Detected');
    });
  });
}
