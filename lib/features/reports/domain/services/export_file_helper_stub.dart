import 'export_file_helper.dart';

class _ExportFileHelperStub implements ExportFileHelper {
  @override
  Future<void> saveAndShare({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    throw UnsupportedError('File export is not supported on this platform.');
  }
}

final ExportFileHelper exportFileHelper = _ExportFileHelperStub();
