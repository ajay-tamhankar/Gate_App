import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CONTRACT test for the payload this app posts as `recognized`.
///
/// The risk this covers is specific and expensive: recognition happens here,
/// extraction happens in vistar_CRM, and the only thing joining them is the
/// shape of one JSON object. Rename a key on either side and the phone reads
/// the page perfectly while the server finds nothing — with no error anywhere,
/// because an unusable payload is simply ignored and the photo is read
/// instead. It would look like the OCR got worse.
///
/// So test/fixtures/mlkit_payload.json is checked in on BOTH sides. An
/// identical copy lives at scripts/fixtures/mlkit_payload.json in the backend,
/// where docscan's mlkit.service normalises it and the gate-challan profile
/// extracts from it, asserting the same five values this file asserts are
/// present. If the two copies drift, one of the two suites fails.
///
/// What this cannot cover: whether ML Kit on a real phone produces this shape.
/// That is verified on-device — the plugin's own types cannot be constructed
/// in a unit test.
void main() {
  late Map<String, dynamic> payload;

  setUp(() {
    payload = jsonDecode(
      File('test/fixtures/mlkit_payload.json').readAsStringSync(),
    ) as Map<String, dynamic>;
  });

  group('the recognized payload', () {
    test('nests blocks -> lines -> elements', () {
      // This nesting IS the contract. mlkit.service walks exactly it.
      final blocks = payload['blocks'] as List;
      expect(blocks, isNotEmpty);

      for (final block in blocks) {
        final lines = (block as Map)['lines'] as List;
        expect(lines, isNotEmpty, reason: 'a block with no lines is dropped server-side');
        for (final line in lines) {
          final elements = (line as Map)['elements'] as List;
          expect(elements, isNotEmpty, reason: 'a line with no elements is dropped server-side');
        }
      }
    });

    test('every element carries text and a bounding box', () {
      // Geometry is the whole reason for sending this rather than plain text:
      // without boxes the server falls back to text-only matching, which is
      // markedly worse and looks like an extractor regression rather than a
      // lost field here.
      for (final block in payload['blocks'] as List) {
        for (final line in (block as Map)['lines'] as List) {
          for (final el in (line as Map)['elements'] as List) {
            final e = el as Map;
            expect(e['text'], isA<String>());
            expect((e['text'] as String).trim(), isNotEmpty);

            final box = e['boundingBox'] as Map;
            for (final key in ['left', 'top', 'right', 'bottom']) {
              expect(box[key], isA<num>(), reason: '$key must be a number');
            }
            expect(box['right'], greaterThan(box['left']));
            expect(box['bottom'], greaterThan(box['top']));
          }
        }
      }
    });

    test('carries the flat text as well', () {
      // The server prefers this for the stored raw_text; without it the text
      // is rebuilt from elements and loses the engine's own line breaks.
      expect(payload['text'], isA<String>());
      expect((payload['text'] as String), contains('526010829'));
    });

    test('holds the values the gate form needs', () {
      // Asserted on the SERVER too, against a byte-identical copy of this
      // file. These five are what the backend suite extracts from it.
      final text = payload['text'] as String;
      for (final expected in [
        '526010829', // invoice number
        '05.09.2026', // invoice date
        '5501232425', // PO number
        '376905447', // vendor code
        'MH12KM7833', // vehicle number
      ]) {
        expect(text, contains(expected));
      }
    });

    test('survives a JSON round trip, which is how it is posted', () {
      // It travels as a STRING in a multipart field, so anything that does not
      // round-trip is lost in transit rather than at the boundary where it
      // would be noticed.
      final round = jsonDecode(jsonEncode(payload)) as Map<String, dynamic>;
      expect(round['blocks'], hasLength((payload['blocks'] as List).length));
      expect(round['text'], payload['text']);
    });

    test('the traps that broke real scans are present, so extraction is exercised', () {
      final text = payload['text'] as String;
      // "Invoice" sits inside "Total Invoice Value", which once returned the
      // AMOUNT as the invoice number.
      expect(text, contains('Total Invoice Value'));
      // "from" once matched a bare 'From' vendor label and returned "GRN".
      expect(text, contains('net from GRN'));
    });
  });
}
