import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gate_entry_controller.dart';
import '../../../../core/auth/session_controller.dart';
import '../../../../core/auth/session_state.dart';
import '../../../reports/data/audit_repository_impl.dart';
import '../../data/dto/create_gate_entry_request.dart';
import '../../data/dto/gate_entry_item_response.dart';
import '../../domain/usecases/upload_gate_entry_attachment_usecase.dart';
import 'attachment_cache_controller.dart';

class GateEntryFormController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submit(Map<String, dynamic> params,
      {String? attachmentFileName, String? attachmentPath, List<int>? bytes}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      
      final items = (params['items'] as List).map((i) => GateEntryItemResponse(
        materialCode: i['material_code'],
        poNumber: i['po_number'],
        challanQty: i['challan_qty'],
        uom: 'NOS',
      )).toList();

      final request = CreateGateEntryRequest(
        challanNo: params['challan_no'],
        vendorName: params['vendor_name'],
        vehicleNo: params['vehicle_no'],
        transporterName: params['transporter_name'],
        gateMovement: params['gate_movement'],
        items: items,
      );

      final created = await ref.read(gateEntryControllerProvider.notifier)
          .createEntry(request);

      if (created == null) {
        throw Exception('Failed to create gate entry');
      }

      if (attachmentFileName != null &&
          attachmentFileName.isNotEmpty &&
          (attachmentPath != null || bytes != null)) {
        final uploadResponse = await ref
            .read(uploadGateEntryAttachmentUseCaseProvider)
            .execute(
              created.id,
              fileName: attachmentFileName,
              filePath: attachmentPath,
              bytes: bytes,
            );

        if (!uploadResponse.success) {
          throw Exception(uploadResponse.message.isNotEmpty
              ? uploadResponse.message
              : 'Failed to upload attachment');
        }

        if (uploadResponse.data != null) {
          ref
              .read(attachmentCacheProvider.notifier)
              .addAttachment(created.id, uploadResponse.data!);
        }
      }

      final session = ref.read(sessionControllerProvider);
      final userId = session is Authenticated ? session.userId : 'Unknown';
      final role = session is Authenticated ? session.role.label : 'Unknown';

      await ref.read(auditRepositoryProvider).logAction(
          userId,
          role,
          'Gate Entry',
          'Create',
          'User triggered ${params['gate_movement']} Entry for Challan ${params['challan_no']} (Vendor: ${params['vendor_name']})');

      // fetchEntries is automatically called within createEntry in gateEntryController
    });
  }
}

final gateEntryFormControllerProvider =
    AsyncNotifierProvider<GateEntryFormController, void>(
  GateEntryFormController.new,
);
