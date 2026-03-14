import 'entities/gate_entry.dart';

abstract class GateEntryRepository {
  Future<List<GateEntry>> getGateEntries();
  Future<GateEntry> getGateEntryDetail(String id);
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
  });
}
