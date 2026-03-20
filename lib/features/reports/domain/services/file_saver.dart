import 'dart:typed_data';

import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart';

abstract class FileSaver {
  Future<void> saveFile(Uint8List bytes, String fileName, String mimeType);
}

FileSaver getFileSaver() => getFileSaverImpl();
