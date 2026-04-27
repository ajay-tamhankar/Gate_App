import 'package:file_picker/file_picker.dart';
import '../../reconciliation/domain/models/grn_import_models.dart';

/// Sealed state machine for GRN CSV upload flow.
sealed class GrnUploadState {
  const GrnUploadState();
}

/// No file selected yet.
class GrnUploadIdle extends GrnUploadState {
  const GrnUploadIdle();
}

/// A valid CSV/XLSX file has been selected, ready to upload.
class GrnUploadFileSelected extends GrnUploadState {
  const GrnUploadFileSelected(this.file);
  final PlatformFile file;
}

/// Upload in progress.
class GrnUploadLoading extends GrnUploadState {
  const GrnUploadLoading(this.file);
  final PlatformFile file;
}

/// Upload succeeded.
class GrnUploadSuccess extends GrnUploadState {
  const GrnUploadSuccess(this.message, {this.result});
  final String message;
  final GrnImportResult? result;
}

/// Upload or validation failed.
class GrnUploadError extends GrnUploadState {
  const GrnUploadError(this.message);
  final String message;
}
