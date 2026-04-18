import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'export_file_helper.dart';

class _ExportFileHelperIo implements ExportFileHelper {
  static const MethodChannel _fileChannel = MethodChannel('gate_reco/files');

  @override
  Future<void> saveAndShare({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    if (Platform.isAndroid) {
      final saved = await _saveToAndroidDownloads(
        fileName: fileName,
        bytes: bytes,
        mimeType: mimeType,
      );
      if (!saved) {
        throw Exception('Could not save file to Downloads folder');
      }
      return;
    }

    // On iOS, direct saving to a public generic Downloads folder is not supported natively 
    // without user interaction. Bringing up the Share Sheet (so they can select "Save to Files") is standard.
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: mimeType)],
      text: 'Exported $fileName',
    );
  }

  Future<bool> _saveToAndroidDownloads({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    try {
      final savedUri = await _fileChannel.invokeMethod<String>(
        'saveFileToDownloads',
        <String, dynamic>{
          'fileName': fileName,
          'mimeType': mimeType,
          'bytes': Uint8List.fromList(bytes),
        },
      );
      return savedUri != null && savedUri.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

final ExportFileHelper exportFileHelper = _ExportFileHelperIo();
