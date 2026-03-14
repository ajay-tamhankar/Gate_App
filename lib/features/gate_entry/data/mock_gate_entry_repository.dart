import '../domain/entities/gate_entry.dart';
import '../domain/gate_entry_repository.dart';

class MockGateEntryRepository implements GateEntryRepository {
  final List<GateEntry> _mockDB = [
    GateEntry(
      id: 'GE-1001',
      challanNumber: 'CH-2024-001',
      vendorName: 'Acme Corp',
      vehicleNumber: 'KA-01-AB-1234',
      poNumber: 'PO-9921',
      gateDirection: 'Gate In',
      materialCode: 'MAT-A123',
      quantity: 50.0,
      transporterName: 'FastTrack Logistics',
      entryTime: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'Pending',
      createdBy: 'GateSecurity',
    ),
    GateEntry(
      id: 'GE-1002',
      challanNumber: 'CH-2024-002',
      vendorName: 'Globex Inc',
      vehicleNumber: 'MH-12-CD-5678',
      poNumber: 'PO-9922',
      gateDirection: 'Gate Out',
      materialCode: 'MAT-B456',
      quantity: 200.0,
      transporterName: 'Global Freight Systems',
      entryTime: DateTime.now().subtract(const Duration(minutes: 45)),
      status: 'Matched',
      createdBy: 'GateSecurity',
    ),
  ];

  @override
  Future<List<GateEntry>> getGateEntries() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return List.unmodifiable(_mockDB);
  }

  @override
  Future<GateEntry> getGateEntryDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final entry = _mockDB.firstWhere((e) => e.id == id,
        orElse: () => throw Exception('Gate Entry not found'));
    return entry;
  }

  @override
  Future<GateEntry> createGateEntry({
    required String challanNumber,
    required String vendorName,
    required String vehicleNumber,
    required String poNumber,
    required String gateDirection,
    required String materialCode,
    required double quantity,
    required String transporterName,
    String? attachmentFileName,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    final newEntry = GateEntry(
      id: 'GE-${1000 + _mockDB.length + 1}',
      challanNumber: challanNumber,
      vendorName: vendorName,
      vehicleNumber: vehicleNumber,
      poNumber: poNumber,
      gateDirection: gateDirection,
      materialCode: materialCode,
      quantity: quantity,
      transporterName: transporterName,
      attachmentFileName: attachmentFileName,
      entryTime: DateTime.now(),
      status: 'Pending',
      createdBy: 'GateSecurity', // Mocking current user role
    );

    _mockDB.insert(0, newEntry); // Add to top
    return newEntry;
  }
}
