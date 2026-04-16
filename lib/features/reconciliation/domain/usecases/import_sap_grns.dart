import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../../data/sap_grn_repository_impl.dart';
import '../models/grn_import_models.dart';

final importSapGrnsUseCaseProvider = Provider<ImportSapGrnsUseCase>((ref) {
  return ImportSapGrnsUseCase(ref.read(sapGrnRepositoryProvider));
});

class ImportSapGrnsUseCase {
  final SapGrnRepository _repository;

  ImportSapGrnsUseCase(this._repository);

  Future<PlatformFile?> pickFile() async {
    const allowedExtensions = ['csv', 'xlsx'];
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.single;
  }

  Future<ApiResponse<GrnImportResult?>> execute(
    PlatformFile file, {
    bool runReconciliation = false,
  }) {
    return _repository.importGrns(
      fileName: file.name,
      filePath: file.path,
      bytes: file.bytes,
      runReconciliation: runReconciliation,
    );
  }
}
