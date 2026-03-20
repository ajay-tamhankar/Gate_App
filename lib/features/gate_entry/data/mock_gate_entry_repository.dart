import '../domain/models/gate_entry.dart';
import '../domain/models/gate_entry_item.dart';

class MockGateEntryRepository {
  int _idCounter = 1000;

  Future<GateEntry> createGateEntry({
    required String challanNumber,
    required String vendorName,
    required String vehicleNumber,
    required String poNumber,
    required String gateDirection,
    required String materialCode,
    required double quantity,
    required String transporterName,
  }) async {
    final id = 'GE-${_idCounter++}';
    final isGateIn = gateDirection.toLowerCase().contains('in');

    return GateEntry(
      id: id,
      gateEntryNo: id,
      gateTimestamp: DateTime.now(),
      gateMovement:
          isGateIn ? GateMovement.inMovement : GateMovement.outMovement,
      challanNo: challanNumber,
      transporterName: transporterName,
      vehicleNo: vehicleNumber,
      vendorName: vendorName,
      status: 'inward_created',
      items: [
        GateEntryItem(
          id: 'item-$id',
          poNumber: poNumber,
          materialCode: materialCode,
          challanQty: quantity.round(),
          uom: 'NOS',
        ),
      ],
    );
  }
}
