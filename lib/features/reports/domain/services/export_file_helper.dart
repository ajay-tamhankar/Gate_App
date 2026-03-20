import 'export_file_helper_stub.dart'
    if (dart.library.io) 'export_file_helper_io.dart'
    if (dart.library.html) 'export_file_helper_web.dart';

abstract class ExportFileHelper {
  Future<void> saveAndShare({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  });
}

ExportFileHelper getExportFileHelper() => exportFileHelper;
