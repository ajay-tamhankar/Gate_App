import 'dart:typed_data';
import 'file_saver.dart';

class _StubFileSaver implements FileSaver {
  @override
  Future<void> saveFile(Uint8List bytes, String fileName, String mimeType) async {
    throw UnsupportedError('File saving is not supported on this platform.');
  }
}

FileSaver getFileSaverImpl() => _StubFileSaver();
