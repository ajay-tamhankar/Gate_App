import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'file_saver.dart';

class _IoFileSaver implements FileSaver {
  @override
  Future<void> saveFile(Uint8List bytes, String fileName, String mimeType) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(file.path)]);
  }
}

FileSaver getFileSaverImpl() => _IoFileSaver();
