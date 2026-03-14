import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/get_gate_entries.dart';
import 'gate_entry_list_controller.dart';
import '../../../../core/auth/session_controller.dart';
import '../../../../core/auth/session_state.dart';
import '../../../reports/domain/audit_repository.dart';

class GateEntryFormController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit({
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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(gateEntryRepositoryProvider);
      await repository.createGateEntry(
        challanNumber: challanNumber,
        vendorName: vendorName,
        vehicleNumber: vehicleNumber,
        poNumber: poNumber,
        gateDirection: gateDirection,
        materialCode: materialCode,
        quantity: quantity,
        transporterName: transporterName,
        attachmentFileName: attachmentFileName,
      );

      final session = ref.read(sessionControllerProvider);
      final userId = session is Authenticated ? session.userId : 'Unknown';
      final role = session is Authenticated ? session.role.label : 'Unknown';

      await ref.read(auditRepositoryProvider).logAction(
          userId,
          role,
          'Gate Entry',
          'Create',
          'User triggered $gateDirection Entry for Challan $challanNumber (Vendor: $vendorName)');

      // Refresh the list after successful creation
      ref.read(gateEntryListControllerProvider.notifier).refresh();
    });
  }
}

final gateEntryFormControllerProvider =
    AsyncNotifierProvider<GateEntryFormController, void>(
  GateEntryFormController.new,
);
