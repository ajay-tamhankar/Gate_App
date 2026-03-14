import 'dart:math';
import '../domain/reco_repository.dart';
import '../domain/entities/reco_exception.dart';
import '../../gate_entry/domain/entities/gate_entry.dart';

class MockRecoRepository implements RecoRepository {
  final List<RecoException> _mockDB = [];
  bool _hasRunEngine = false;

  // Test Helpers
  void clearForTest() {
    _mockDB.clear();
    _recentGateEntries.clear();
    _sapDatabase.clear();
    _hasRunEngine = false;
  }

  void addGateEntryForTest(GateEntry entry) {
    _recentGateEntries.add(entry);
    _hasRunEngine = false;
  }

  void setupSapMockForTest(String poNumber, Map<String, dynamic> data) {
    _sapDatabase[poNumber] = data;
    _hasRunEngine = false;
  }

  RecoException getExceptionByGateEntryId(String gateEntryId) {
    return _mockDB.firstWhere((e) => e.gateEntryId == gateEntryId,
        orElse: () =>
            throw Exception('Exception not found for gate entry $gateEntryId'));
  }

  // Simulate an SAP Database (Source of Truth)
  final Map<String, Map<String, dynamic>> _sapDatabase = {
    'PO-9921': {
      'materialCode': 'MAT-A123',
      'allowedQty': 50.0,
      'vendor': 'Acme Corp',
      'isClosed': false
    },
    'PO-9922': {
      'materialCode': 'MAT-B456',
      'allowedQty': 200.0,
      'vendor': 'Globex Inc',
      'isClosed': true
    },
    'PO-9923': {
      'materialCode': 'MAT-C789',
      'allowedQty': 100.0,
      'vendor': 'Stark Ind',
      'isClosed': false
    },
  };

  // Simulate recent Gate Entries coming from the Gate Module
  final List<GateEntry> _recentGateEntries = [
    GateEntry(
        id: 'GE-1005',
        challanNumber: 'CH-2024-001',
        vendorName: 'Acme Corp',
        vehicleNumber: 'KA-01-AB-1234',
        poNumber: 'PO-9921',
        gateDirection: 'Gate In',
        materialCode: 'MAT-A123',
        quantity: 50.0,
        transporterName: 'FastTrack',
        entryTime: DateTime.now().subtract(const Duration(hours: 3)),
        status: 'Pending'),
    GateEntry(
        id: 'GE-1006',
        challanNumber: 'CH-2024-002',
        vendorName: 'Globex Inc',
        vehicleNumber: 'MH-12-CD-5678',
        poNumber: 'PO-9922',
        gateDirection: 'Gate In',
        materialCode: 'MAT-B456',
        quantity: 250.0,
        transporterName: 'Global',
        entryTime: DateTime.now().subtract(const Duration(hours: 5)),
        status: 'Pending'), // Qty Mismatch
    GateEntry(
        id: 'GE-1007',
        challanNumber: 'CH-2024-003',
        vendorName: 'Unknown Vendor',
        vehicleNumber: 'RJ-14-EF-9012',
        poNumber: 'PO-0000',
        gateDirection: 'Gate In',
        materialCode: 'MAT-XYZ',
        quantity: 10.0,
        transporterName: 'Local Transport',
        entryTime: DateTime.now().subtract(const Duration(hours: 2)),
        status: 'Pending'), // Wrong PO
    GateEntry(
        id: 'GE-1008',
        challanNumber: 'CH-2024-004',
        vendorName: 'Stark Ind',
        vehicleNumber: 'DL-01-GH-3456',
        poNumber: 'PO-9923',
        gateDirection: 'Gate In',
        materialCode: 'MAT-C789',
        quantity: 100.0,
        transporterName: 'Stark Transport',
        entryTime: DateTime.now().subtract(const Duration(minutes: 30)),
        status: 'Pending'), // Pending GRN
    GateEntry(
        id: 'GE-1009',
        challanNumber: 'CH-2024-005',
        vendorName: 'Globex Inc',
        vehicleNumber: 'MH-12-CD-5678',
        poNumber: 'PO-9922',
        gateDirection: 'Gate In',
        materialCode: 'MAT-B456',
        quantity: 200.0,
        transporterName: 'Global',
        entryTime: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Pending'), // Duplicate
  ];

  void _runReconciliationEngine() {
    _mockDB.clear();
    int excIdCounter = 5521;

    for (var entry in _recentGateEntries) {
      final sapRecord = _sapDatabase[entry.poNumber];

      String status = '';
      String description = '';

      if (sapRecord == null) {
        status = 'Wrong PO/Material GRN';
        description =
            'The Purchase Order ${entry.poNumber} could not be found in SAP.';
      } else if (sapRecord['materialCode'] != entry.materialCode) {
        status = 'Wrong PO/Material GRN';
        description =
            'Material Code mismatch. Expected ${sapRecord['materialCode']}, got ${entry.materialCode}.';
      } else if (sapRecord['vendor'] != entry.vendorName) {
        status = 'Wrong PO/Material GRN';
        description = 'Vendor mismatch for PO ${entry.poNumber}.';
      } else if (sapRecord['isClosed'] == true) {
        status = 'Duplicate GRN Detected';
        description =
            'A Goods Receipt has already been posted and closed for ${entry.poNumber}.';
      } else if (entry.quantity > (sapRecord['allowedQty'] as double)) {
        status = 'Quantity Mismatch';
        description =
            'Challan quantity (${entry.quantity}) exceeds allowed SAP PO quantity (${sapRecord['allowedQty']}).';
      } else if (entry.id == 'GE-1008') {
        status = 'Pending GRN';
        description =
            'System is awaiting warehouse team to trigger Goods Receipt Note.';
      } else {
        status = 'Matched';
        description = 'Successfully reconciled Gate Entry with SAP Database.';
      }

      _mockDB.add(RecoException(
        id: 'EXC-${excIdCounter++}',
        gateEntryId: entry.id,
        poNumber: entry.poNumber,
        status: status,
        description: description,
        createdAt: entry.entryTime.add(Duration(minutes: Random().nextInt(15))),
      ));
    }

    _hasRunEngine = true;
  }

  @override
  Future<List<RecoException>> getExceptions() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!_hasRunEngine) {
      _runReconciliationEngine();
    }
    // Return everything except "Matched" so the list only acts as an exception dashboard
    return List.unmodifiable(_mockDB.where((e) => e.status != 'Matched'));
  }

  @override
  Future<RecoException> getExceptionDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockDB.firstWhere((e) => e.id == id,
        orElse: () => throw Exception('Exception not found'));
  }

  @override
  Future<void> resolveException(String id, String resolutionNotes) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _mockDB.indexWhere((e) => e.id == id);
    if (index != -1) {
      final old = _mockDB[index];
      _mockDB[index] = RecoException(
        id: old.id,
        gateEntryId: old.gateEntryId,
        poNumber: old.poNumber,
        status: 'Resolved',
        description: '${old.description}\n\nResolution: $resolutionNotes',
        createdAt: old.createdAt,
        resolvedAt: DateTime.now().toIso8601String(),
        resolvedBy: 'WHManager',
      );
    } else {
      throw Exception('Exception not found');
    }
  }
}
