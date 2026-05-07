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
import '../../../reconciliation/domain/models/grn_import_models.dart';

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

  /// Uploads the selected file. Reconciliation always runs automatically on the backend.
  Future<void> upload() async {
    final current = state;
    if (current is! GrnUploadFileSelected) return;

    state = GrnUploadLoading(current.file);

    try {
      final service = ref.read(grnImportServiceProvider);
      final result = await service.importGrn(current.file);

      // Invalidate relevant providers to refresh UI
      ref.invalidate(dashboardControllerProvider);
      ref.invalidate(warehouseDashboardProvider);
      ref.invalidate(warehouseReconciliationSummaryProvider);
      ref.invalidate(warehouseManagerReconciliationsProvider);
      ref.invalidate(warehouseManagerDashboardSummaryProvider);
      ref.invalidate(reconciliationDashboardProvider);
      _scheduleReconciliationRefresh();

      _postAuditLog();

      // Build success message from new backend response fields
      final msg = _buildSuccessMessage(result);

      state = GrnUploadSuccess(msg, result: result);
    } on GrnImportException catch (e) {
      state = GrnUploadError(e.message);
    } catch (e) {
      state = GrnUploadError('Upload Failed: ${e.toString()}');
    }
  }

  /// Constructs the success message from the import result, using new backend fields.
  /// Provides backward compatibility for older response structures.
  String _buildSuccessMessage(GrnImportResult? result) {
    if (result == null) {
      return 'Import complete, reconciliation running in background.';
    }

    final messageParts = <String>[];

    // Primary: Imported count (use new field with fallback to legacy)
    final importedCount = result.importedCount ??
        result.upsertedRowCount ??
        result.processed ??
        0;
    messageParts.add('Import complete, reconciliation running in background.');
    if (importedCount > 0) {
      messageParts.add('Imported $importedCount GRN records.');
    }

    final reconciliationMessage = result.reconciliation?.message;
    if (reconciliationMessage != null && reconciliationMessage.isNotEmpty) {
      messageParts.add(reconciliationMessage);
    }

    // Tertiary: Skipped count with message
    final skippedCount = result.skippedCount ?? 0;
    if (skippedCount > 0) {
      if (result.skippedMessage != null && result.skippedMessage!.isNotEmpty) {
        messageParts.add(result.skippedMessage!);
      } else {
        messageParts.add('$skippedCount rows were skipped');
      }
    }

    return messageParts.join('\n');
  }

  void _scheduleReconciliationRefresh() {
    Future<void>.delayed(const Duration(seconds: 3)).then((_) {
      ref.invalidate(dashboardControllerProvider);
      ref.invalidate(warehouseDashboardProvider);
      ref.invalidate(warehouseReconciliationSummaryProvider);
      ref.invalidate(warehouseManagerReconciliationsProvider);
      ref.invalidate(warehouseManagerDashboardSummaryProvider);
      ref.invalidate(reconciliationDashboardProvider);
    });
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

final grnUploadProvider = NotifierProvider<GrnUploadNotifier, GrnUploadState>(
  GrnUploadNotifier.new,
);
