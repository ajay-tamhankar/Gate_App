import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_response.dart';
import '../../data/sap_grn_repository_impl.dart';

final importSapGrnsUseCaseProvider = Provider<ImportSapGrnsUseCase>((ref) {
  return ImportSapGrnsUseCase(ref.read(sapGrnRepositoryProvider));
});

class ImportSapGrnsUseCase {
  final SapGrnRepository _repository;

  ImportSapGrnsUseCase(this._repository);

  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return null;
    return result.files.single;
  }

  Future<ApiResponse<void>> execute(PlatformFile file) {
    return _repository.importGrns(
      fileName: file.name,
      filePath: file.path,
      bytes: file.bytes,
    );
  }
}
