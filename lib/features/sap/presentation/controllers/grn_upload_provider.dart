import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/session_controller.dart';
import '../../../../core/auth/session_state.dart';
import '../../../../features/dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../../features/reports/data/audit_repository_impl.dart';
import '../../../../features/warehouse/presentation/controllers/warehouse_providers.dart';
import '../../data/grn_import_service.dart';
import '../../domain/grn_upload_state.dart';

/// Riverpod notifier that manages the GRN file upload workflow.
class GrnUploadNotifier extends Notifier<GrnUploadState> {
  @override
  GrnUploadState build() => const GrnUploadIdle();

  /// Opens the system file picker restricted to supported files.
  Future<void> pickFile() async {
    if (state is GrnUploadLoading) return;
    const allowedExtensions = ['csv', 'xlsx'];

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: kIsWeb,
      withReadStream: !kIsWeb,
    );

    if (result == null || result.files.isEmpty) {
      if (state is GrnUploadError || state is GrnUploadIdle) {
        state = const GrnUploadIdle();
      }
      return;
    }

    final file = result.files.first;

    if (!_isSupportedFile(file.name)) {
      state = const GrnUploadError('Only CSV and XLSX files are supported.');
      return;
    }

    state = GrnUploadFileSelected(file);
  }

  /// Toggles the auto-reconciliation flag for the selected file.
  void toggleReconciliation(bool value) {
    final current = state;
    if (current is GrnUploadFileSelected) {
      state = GrnUploadFileSelected(current.file, runReconciliation: value);
    }
  }

  /// Uploads the currently selected import file.
  Future<void> upload() async {
    final current = state;
    if (current is! GrnUploadFileSelected) return;

    final runRecon = current.runReconciliation;
    state = GrnUploadLoading(current.file, runReconciliation: runRecon);

    try {
      final service = ref.read(grnImportServiceProvider);
      final result = await service.importGrn(
        current.file,
        runReconciliation: runRecon,
      );

      // Invalidate relevant providers to refresh UI
      ref.invalidate(dashboardControllerProvider);
      ref.invalidate(warehouseDashboardProvider);
      ref.invalidate(warehouseReconciliationSummaryProvider);
      ref.invalidate(warehouseManagerReconciliationsProvider);
      ref.invalidate(warehouseManagerDashboardSummaryProvider);

      _postAuditLog();

      final imported = result?.importedCount ?? result?.processed ?? 0;
      String msg = 'Successfully imported $imported records';

      if (runRecon) {
        if (result?.summary != null) {
          final matched = result!.summary!.gateEntries.matched;
          final total = result.summary!.gateEntries.total;
          msg = 'Imported $imported & Reconciled: $matched/$total Matched';
        } else {
          msg = 'Imported $imported records. Reconciliation is in progress.';
        }
      }

      state = GrnUploadSuccess(msg, result: result);
    } on GrnImportException catch (e) {
      state = GrnUploadError(e.message);
    } catch (e) {
      state = GrnUploadError('Upload Failed: ${e.toString()}');
    }
  }

  /// Resets the notifier back to idle so the card can be reused.
  void reset() => state = const GrnUploadIdle();

  bool _isSupportedFile(String fileName) {
    final normalized = fileName.toLowerCase();
    return normalized.endsWith('.csv') || normalized.endsWith('.xlsx');
  }

  Future<void> _postAuditLog() async {
    try {
      final session = ref.read(sessionControllerProvider);
      final userId = session is Authenticated ? session.userId : 'Unknown';
      final role = session is Authenticated ? session.role.label : 'Unknown';

      await ref.read(auditRepositoryProvider).logAction(
            userId,
            role,
            'SAP Integration',
            'IMPORT_GRN',
            'User imported GRN data from CSV/XLSX file.',
          );
    } catch (_) {
      // Audit logging is best-effort only.
    }
  }
}

final grnUploadProvider =
    NotifierProvider<GrnUploadNotifier, GrnUploadState>(
  GrnUploadNotifier.new,
);
