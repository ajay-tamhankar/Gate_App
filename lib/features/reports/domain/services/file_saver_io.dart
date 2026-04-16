import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import 'file_saver.dart';

class _IoFileSaver implements FileSaver {
  @override
  Future<void> saveFile(Uint8List bytes, String fileName, String mimeType) async {
    final directory = await _resolveExportDirectory();
    final file = File('${directory.path}/$fileName');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<Directory> _resolveExportDirectory() async {
    if (Platform.isAndroid) {
      final downloadDirs =
          await getExternalStorageDirectories(type: StorageDirectory.downloads);
      if (downloadDirs != null && downloadDirs.isNotEmpty) {
        final exportDir = Directory('${downloadDirs.first.path}/GateRecoExports');
        if (!await exportDir.exists()) {
          await exportDir.create(recursive: true);
        }
        return exportDir;
      }

      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final exportDir = Directory('${externalDir.path}/GateRecoExports');
        if (!await exportDir.exists()) {
          await exportDir.create(recursive: true);
        }
        return exportDir;
      }
    }

    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        return downloadsDir;
      }
    } catch (_) {
      // Not supported on some mobile platforms.
    }

    return getApplicationDocumentsDirectory();
  }
}

FileSaver getFileSaverImpl() => _IoFileSaver();
