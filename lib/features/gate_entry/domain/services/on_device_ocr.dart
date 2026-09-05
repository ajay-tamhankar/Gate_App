import 'dart:convert';
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Reads a photographed document ON THE PHONE, before it is uploaded.
///
/// WHY
///
/// The server's OCR (Tesseract) is at its worst on exactly what a guard
/// produces: a handheld photo of a dense invoice in gate lighting. Every one
/// of the first ten production scans came back flagged blurred, and page
/// confidence swung between 58 and 86 — the difference between three usable
/// fields and eleven. ML Kit is built for camera frames, is free, needs no API
/// key, and the image never leaves the device to be read.
///
/// WHAT THIS DOES NOT DO
///
/// It does not interpret anything. Deciding which run of characters is a PO
/// number, whether a GSTIN's check digit holds, or whether a vendor exists
/// stays on the server, where it can be fixed in minutes for every phone at
/// once. This app has no CI: an extractor bug fixed here would need a rebuild
/// and a sideload on every device. So the phone reads, the server decides.
///
/// The payload below is the shape `docscan/services/mlkit.service.js`
/// normalises. Keep them in step: the server accepts several box
/// serialisations precisely so a rename here cannot silently cost us all the
/// geometry, but the block/line/element nesting is the contract.
class OnDeviceOcr {
  OnDeviceOcr._();

  /// Latin covers every document seen at the gate — Indian tax invoices are
  /// printed in English even where the vendor's name is not.
  static final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  /// Recognise [imagePath] and return the payload to post as `recognized`.
  ///
  /// Returns null when recognition is unavailable or finds nothing — the
  /// caller then simply uploads the photo and the server reads it as before.
  /// A failure here must never cost the guard the scan.
  static Future<Map<String, dynamic>?> recognise(String imagePath) async {
    // Web has no ML Kit. The server path already handles that build.
    if (kIsWeb) return null;

    try {
      final recognized =
          await _recognizer.processImage(InputImage.fromFilePath(imagePath));

      final blocks = <Map<String, dynamic>>[];
      for (final block in recognized.blocks) {
        final lines = <Map<String, dynamic>>[];
        for (final line in block.lines) {
          final elements = <Map<String, dynamic>>[];
          for (final el in line.elements) {
            final text = el.text.trim();
            if (text.isEmpty) continue;
            elements.add({'text': text, 'boundingBox': _rect(el.boundingBox)});
          }
          if (elements.isEmpty) continue;
          lines.add({
            'text': line.text,
            'boundingBox': _rect(line.boundingBox),
            'elements': elements,
          });
        }
        if (lines.isEmpty) continue;
        blocks.add({'text': block.text, 'boundingBox': _rect(block.boundingBox), 'lines': lines});
      }

      // Nothing legible. Say so by returning null rather than posting an empty
      // payload the server would have to reason about.
      if (blocks.isEmpty) return null;

      return {'text': recognized.text, 'blocks': blocks};
    } catch (e) {
      // Model still downloading, an unreadable file, a device without Play
      // Services — all end the same way: fall back to server-side OCR.
      debugPrint('[OnDeviceOcr] recognition unavailable, falling back: $e');
      return null;
    }
  }

  /// The server accepts left/top/right/bottom, so send the Rect as-is.
  static Map<String, double> _rect(Rect box) => {
        'left': box.left,
        'top': box.top,
        'right': box.right,
        'bottom': box.bottom,
      };

  /// Encoded for a multipart field. The server parses a JSON string there.
  static String encode(Map<String, dynamic> payload) => jsonEncode(payload);

  /// Free the native recogniser. Called when the form is disposed; recognition
  /// is per-scan and holding the model open for a screen nobody is using costs
  /// memory on the low-end phones these run on.
  static Future<void> dispose() async {
    try {
      await _recognizer.close();
    } catch (_) {
      // Closing twice, or before it ever opened, is not worth surfacing.
    }
  }
}
