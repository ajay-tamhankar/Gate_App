// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'export_file_helper.dart';

class _ExportFileHelperWeb implements ExportFileHelper {
  @override
  Future<void> saveAndShare({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}

final ExportFileHelper exportFileHelper = _ExportFileHelperWeb();
