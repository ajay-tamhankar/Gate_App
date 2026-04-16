import 'dart:async';

class MockRecoRepository {
  final List<Map<String, dynamic>> _sapData = [];
  final List<Map<String, dynamic>> _gateEntries = [];
  final List<Map<String, dynamic>> _exceptions = [];

  void clearForTest() {
    _sapData.clear();
    _gateEntries.clear();
    _exceptions.clear();
  }

  // Setup SAP Mock Data
  void setupSapMockForTest(String poNumber, Map<String, dynamic> data) {
    _sapData.add({
      'poNumber': poNumber,
      ...data,
    });
  }

  // Add Gate Entry
  void addGateEntryForTest(dynamic entry) {
    final items = (entry.items as List?) ?? const [];
    final firstItem = items.isNotEmpty ? items.first : null;

    _gateEntries.add({
      'id': entry.id,
      // Reconciliation compares SAP GRNs to the gate entry's first item.
      'poNumber': firstItem?.poNumber ?? '',
      'materialCode': firstItem?.materialCode ?? '',
      'quantity': firstItem?.challanQty ?? 0,
      'vendor': entry.vendorName,
    });
  }

  // MAIN RECONCILIATION ENGINE
  Future<List<Map<String, dynamic>>> getExceptions() async {
    _exceptions.clear();

    for (var entry in _gateEntries) {
      final sap = _sapData.firstWhere(
        (e) => e['poNumber'] == entry['poNumber'],
        orElse: () => {},
      );

      if (sap.isEmpty) {
        _exceptions.add({
          'id': entry['id'],
          'status': 'Pending GRN',
          'description': 'No GRN found in SAP',
        });
        continue;
      }

      // Duplicate GRN
      if (sap['isClosed'] == true) {
        _exceptions.add({
          'id': entry['id'],
          'status': 'Duplicate GRN Detected',
          'description': 'GRN already closed',
        });
        continue;
      }

      // Material mismatch
      if (sap['materialCode'] != entry['materialCode']) {
        _exceptions.add({
          'id': entry['id'],
          'status': 'Wrong PO/Material GRN',
          'description': 'Material mismatch',
        });
        continue;
      }

      // Quantity check
      if (sap['allowedQty'] != entry['quantity']) {
        _exceptions.add({
          'id': entry['id'],
          'status': 'Quantity Mismatch',
          'description': 'Quantity does not match SAP',
        });
        continue;
      }

      // Matched
      _exceptions.add({
        'id': entry['id'],
        'status': 'Matched',
        'description': 'All data matched',
      });
    }

    return _exceptions;
  }

  // Get Exception by Gate Entry ID
  dynamic getExceptionByGateEntryId(String id) {
    return _exceptions.firstWhere((e) => e['id'] == id);
  }

  // Resolve Exception
  Future<void> resolveException(String id, String remark) async {
    final index = _exceptions.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      _exceptions[index]['status'] = 'Resolved';
      _exceptions[index]['description'] = remark;
    }
  }

  // Get Exception Detail
  Future<dynamic> getExceptionDetail(String id) async {
    return _exceptions.firstWhere((e) => e['id'] == id);
  }
}
