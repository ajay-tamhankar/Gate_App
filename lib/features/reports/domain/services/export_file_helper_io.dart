import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'export_file_helper.dart';

class _ExportFileHelperIo implements ExportFileHelper {
  @override
  Future<void> saveAndShare({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
  }
}

final ExportFileHelper exportFileHelper = _ExportFileHelperIo();
