import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gate_reco_app/features/gate_entry/domain/models/scanned_document.dart';

/// CONTRACT test: the client model against responses the backend actually
/// produced.
///
/// The fixtures in test/fixtures were captured by running the real
/// vistar_CRM gate scan service (offline Tesseract over a rendered challan)
/// and serialising exactly what its controller sends. So this is not a test
/// of hand-written JSON that agrees with itself — it fails if the server's
/// shape and the client's expectations drift apart, which is the actual
/// integration risk for a feature split across two repositories.
///
/// Re-capture them by running, in the vistar_CRM repo, the snippet documented
/// in src/modules/docscan/README.md.
void main() {
  Map<String, dynamic> load(String name) {
    final file = File('test/fixtures/$name');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  ScannedDocument parse(String name) =>
      ScannedDocument.fromJson(load(name)['data'] as Map<String, dynamic>);

  group('a readable challan', () {
    late ScannedDocument scan;
    setUp(() => scan = parse('scan_response.json'));

    test('parses and reports itself readable', () {
      expect(scan.readable, isTrue);
      expect(scan.hasDraft, isTrue);
      expect(scan.engine, 'tesseract');
    });

    test('the draft carries the values the gate form needs', () {
      // These key names ARE the contract — POST /gate-entries accepts this
      // body unchanged, so a rename on either side must break a test.
      expect(scan.draft, containsPair('gateMovement', 'in'));
      expect(scan.draft!['challanNo'], isNotEmpty);
      expect(scan.draft!['documentDate'], matches(r'^\d{4}-\d{2}-\d{2}$'));
      expect(scan.draft!['vehicleNo'], isNotEmpty);
    });

    test('items are separated from header fields', () {
      // The form fills header controllers and challan-row controllers from
      // different places, so conflating them would put an item into a header
      // field.
      expect(scan.headerFields.containsKey('items'), isFalse);
      expect(scan.items, isNotEmpty);
      expect(scan.items.first.keys, contains('materialCode'));
    });

    test('every SCANNED field is explainable', () {
      // Every value the sheet offers must carry confidence and a flag, or it
      // would render as trustworthy by default. `gateMovement` is the one
      // draft key with no review entry — the server injects it because the
      // app already knows the direction, so it was never read off the paper
      // and the sheet deliberately does not present it.
      final unexplained = scan.headerFields.keys
          .where((k) => !scan.review.containsKey(k))
          .toSet();
      expect(unexplained, {'gateMovement'},
          reason: 'a scanned field with no review entry would render as trusted');
    });

    test('low-confidence fields are flagged, and that is what the UI keys on',
        () {
      expect(scan.flaggedFields, isNotEmpty);
      for (final key in scan.flaggedFields) {
        expect(scan.review[key]!.needsReview, isTrue);
        expect(scan.review[key]!.confidence, lessThan(0.75));
      }
    });

    test('a checksum-verified field is trusted and not flagged', () {
      // The GSTIN carries a mod-36 check digit, so the backend proves it
      // rather than guessing — the UI shows it ticked instead of asking the
      // guard to re-read 15 characters.
      final gstin = scan.review['gstin'];
      expect(gstin, isNotNull);
      expect(gstin!.verifiedBy, contains('checksum'));
      expect(gstin.isVerified, isTrue);
      expect(gstin.needsReview, isFalse);
    });

    test('field provenance survives parsing', () {
      final challan = scan.review['challanNo']!;
      // "label:Challan No" is what lets the sheet say WHERE to look on the
      // paper, which is more use to a guard than a bare percentage.
      expect(challan.source, startsWith('label:'));
    });

    test('an unresolved vendor offers candidates instead of guessing', () {
      final vendor = scan.vendorMatch!;
      expect(vendor.isResolved, isFalse);
      expect(scan.review['vendorCode']!.needsReview, isTrue);
      expect(scan.warningWithCode('VENDOR_NOT_RESOLVED'), isNotNull);
    });
  });

  group('a duplicate challan', () {
    late ScannedDocument scan;
    setUp(() => scan = parse('scan_response_duplicate.json'));

    test('the vendor resolves and is therefore not flagged', () {
      expect(scan.vendorMatch!.isResolved, isTrue);
      expect(scan.draft!['vendorCode'], 'V10023');
      // Resolved against the master, so corroborated by data we already hold.
      expect(scan.review['vendorCode']!.needsReview, isFalse);
    });

    test('the duplicate is reported before the guard fills the form', () {
      final dup = scan.duplicateChallan!;
      expect(dup.checked, isTrue);
      expect(dup.isDuplicate, isTrue);
      expect(dup.existingGateEntryNo, 'GE-2026-0042');
    });

    test('and surfaces as a blocking warning naming the existing entry', () {
      final warning = scan.warningWithCode('DUPLICATE_CHALLAN')!;
      // isBlocking drives the red banner: submitting this WILL be rejected
      // with a 409, so it has to outrank the field-level noise.
      expect(warning.isBlocking, isTrue);
      expect(warning.message, contains('GE-2026-0042'));
    });
  });

  group('an unreadable photo', () {
    late ScannedDocument scan;
    setUp(() => scan = parse('scan_response_unreadable.json'));

    test('no draft is offered', () {
      // The backend guarantees any draft it returns is submittable, so "no
      // draft" is the honest answer rather than a stub that fails on save.
      expect(scan.hasDraft, isFalse);
      expect(scan.draft, isNull);
      expect(scan.items, isEmpty);
    });

    test('the reason is actionable and classified as a photo problem', () {
      final noText = scan.warningWithCode('NO_TEXT_DETECTED');
      expect(noText, isNotNull);
      // isPhotoQuality is what makes the sheet offer "Retake" — retaking
      // fixes more than correcting six fields by hand.
      expect(noText!.isPhotoQuality, isTrue);
      expect(scan.warningWithCode('NOTHING_TO_AUTOFILL'), isNotNull);
    });

    test('headerFields is empty rather than throwing', () {
      expect(scan.headerFields, isEmpty);
    });

    test('review still reports what WAS attempted', () {
      // Review survives an unreadable photo on purpose: it says the vendor
      // could not be resolved, which is more useful than an empty response.
      // With no draft there is nothing for the sheet to display, so this
      // cannot mislead.
      expect(scan.review.keys, contains('vendorCode'));
      expect(scan.review['vendorCode']!.needsReview, isTrue);
    });
  });

  group('defensive parsing', () {
    test('an empty object does not throw', () {
      final scan = ScannedDocument.fromJson(const {});
      expect(scan.readable, isFalse);
      expect(scan.hasDraft, isFalse);
      expect(scan.warnings, isEmpty);
    });

    test('unexpected types are tolerated', () {
      // A field the server later returns as a string instead of a number
      // must not crash a guard's phone mid-shift.
      final scan = ScannedDocument.fromJson(const {
        'readable': true,
        'confidence': '84',
        'draft': {'challanNo': 'DC-1'},
        'review': {
          'challanNo': {'confidence': '0.55', 'needsReview': true}
        },
        'warnings': 'not-a-list',
      });
      expect(scan.pageConfidence, 84);
      expect(scan.review['challanNo']!.confidence, closeTo(0.55, 0.001));
      expect(scan.warnings, isEmpty);
    });
  });
}
