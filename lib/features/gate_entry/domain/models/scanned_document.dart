/// Result of POST /gate-entries/scan — a challan photographed at the barrier,
/// read by the backend's offline OCR.
///
/// The shape mirrors the API deliberately, including the split between
/// [draft] and [review]:
///
///   [draft]  the values, shaped EXACTLY like the body of POST /gate-entries,
///            so it can be submitted unchanged once the guard has confirmed
///            the flagged fields.
///   [review] per-field metadata for the same keys — confidence, and whether
///            the field needs a look.
///
/// Keeping them apart is what makes the feature safe rather than merely
/// convenient. A prefilled value the guard has not looked at is worse than an
/// empty box, because the empty box gets typed correctly and the wrong one
/// gets saved. So the UI must prefill AND flag; see [ScanReviewSheet].
///
/// [draft] is null when nothing usable could be read. The API guarantees that
/// any draft it does return is submittable, so the UI never has to guess
/// whether it is safe to send.
library;

class ScannedDocument {
  const ScannedDocument({
    required this.readable,
    this.scanId,
    this.engine,
    this.pageConfidence,
    this.draft,
    this.review = const {},
    this.vendorMatch,
    this.duplicateChallan,
    this.warnings = const [],
    this.lineItemsFound = 0,
    this.durationMs,
  });

  /// False when the photo could not be read at all (blank, out of focus,
  /// a scanned PDF with no text layer). [warnings] then says why.
  final bool readable;
  final String? scanId;

  /// 'tesseract' for a photo, 'pdf-text' for a digital PDF — the latter is
  /// exact rather than recognised, which is worth surfacing.
  final String? engine;

  /// Mean OCR confidence for the page, 0-100. Distinct from the per-field
  /// confidences: this says how legible the photo was, which is what to show
  /// when everything came back empty.
  final double? pageConfidence;

  /// Submittable body for POST /gate-entries. Null when nothing was read.
  final Map<String, dynamic>? draft;

  /// Keyed by the same names as [draft].
  final Map<String, ScannedFieldReview> review;

  final ScannedVendorMatch? vendorMatch;
  final DuplicateChallanCheck? duplicateChallan;
  final List<ScanWarning> warnings;
  final int lineItemsFound;
  final int? durationMs;

  /// Header values only — the item rows are handled separately.
  Map<String, dynamic> get headerFields {
    final out = <String, dynamic>{};
    (draft ?? const {}).forEach((key, value) {
      if (key != 'items') out[key] = value;
    });
    return out;
  }

  List<Map<String, dynamic>> get items {
    final raw = (draft ?? const {})['items'];
    if (raw is List) {
      return raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    return const [];
  }

  bool get hasDraft => draft != null && draft!.isNotEmpty;

  /// Fields the guard must look at before saving.
  Iterable<String> get flaggedFields =>
      review.entries.where((e) => e.value.needsReview).map((e) => e.key);

  ScanWarning? warningWithCode(String code) =>
      warnings.where((w) => w.code == code).firstOrNull;

  factory ScannedDocument.fromJson(Map<String, dynamic> json) {
    final rawReview = json['review'];
    final review = <String, ScannedFieldReview>{};
    if (rawReview is Map) {
      rawReview.forEach((key, value) {
        if (value is Map) {
          review[key.toString()] =
              ScannedFieldReview.fromJson(value.cast<String, dynamic>());
        }
      });
    }

    final rawWarnings = json['warnings'];
    return ScannedDocument(
      readable: json['readable'] as bool? ?? false,
      scanId: json['scanId']?.toString(),
      engine: json['engine']?.toString(),
      pageConfidence: _toDouble(json['confidence']),
      draft: json['draft'] is Map
          ? (json['draft'] as Map).cast<String, dynamic>()
          : null,
      review: review,
      vendorMatch: json['vendorMatch'] is Map
          ? ScannedVendorMatch.fromJson(
              (json['vendorMatch'] as Map).cast<String, dynamic>())
          : null,
      duplicateChallan: json['duplicateChallan'] is Map
          ? DuplicateChallanCheck.fromJson(
              (json['duplicateChallan'] as Map).cast<String, dynamic>())
          : null,
      warnings: rawWarnings is List
          ? rawWarnings
              .whereType<Map>()
              .map((w) => ScanWarning.fromJson(w.cast<String, dynamic>()))
              .toList()
          : const [],
      lineItemsFound: _toInt(json['lineItemsFound']) ?? 0,
      durationMs: _toInt(json['durationMs']),
    );
  }
}

class ScannedFieldReview {
  const ScannedFieldReview({
    required this.confidence,
    required this.needsReview,
    this.source,
    this.reason,
    this.note,
    this.alternatives = const [],
    this.verifiedBy = const [],
  });

  /// 0..1. Not a probability — a score combining OCR confidence with
  /// whatever structural checks the field supports.
  final double confidence;

  /// The field was read but should be glanced at. The UI must show this.
  final bool needsReview;

  /// Where the value came from: 'label:Challan No', 'shape', 'geometry',
  /// 'vendor-master', 'derived:invoiceNo'. Worth showing on a flagged field —
  /// "read next to the label Challan No" tells the guard where to look.
  final String? source;
  final String? reason;

  /// Set when the backend repaired what it read (e.g. a checksum-corrected
  /// GSTIN), so the change can be disclosed rather than hidden.
  final String? note;

  /// Runner-up readings. When a field is wrong the right answer is usually
  /// here, which turns a correction into a tap.
  final List<Map<String, dynamic>> alternatives;

  /// Checks this value PASSED: 'checksum', 'tax-arithmetic',
  /// 'amount-in-words', 'trip-vehicle'. Lets the UI say why it is trusted.
  final List<String> verifiedBy;

  bool get isVerified => verifiedBy.isNotEmpty;

  factory ScannedFieldReview.fromJson(Map<String, dynamic> json) {
    final alts = json['alternatives'];
    final verified = json['verifiedBy'];
    return ScannedFieldReview(
      confidence: _toDouble(json['confidence']) ?? 0,
      needsReview: json['needsReview'] as bool? ?? false,
      source: json['source']?.toString(),
      reason: json['reason']?.toString(),
      note: json['note']?.toString(),
      alternatives: alts is List
          ? alts
              .whereType<Map>()
              .map((e) => e.cast<String, dynamic>())
              .toList()
          : const [],
      verifiedBy: verified is List
          ? verified.map((e) => e.toString()).toList()
          : const [],
    );
  }
}

/// The scanned vendor resolved against gate.vendor_master.
///
/// [vendorCode] is null when no single vendor matched clearly — the backend
/// refuses to guess, because a wrong vendor code attaches the consignment to
/// another supplier's account and only surfaces weeks later during GRN
/// reconciliation. [candidates] is then what the guard picks from.
class ScannedVendorMatch {
  const ScannedVendorMatch({
    this.vendorCode,
    this.vendorName,
    required this.confidence,
    this.matchedOn,
    this.candidates = const [],
  });

  final String? vendorCode;
  final String? vendorName;
  final double confidence;
  final String? matchedOn;
  final List<ScannedVendorCandidate> candidates;

  bool get isResolved => (vendorCode ?? '').isNotEmpty;

  factory ScannedVendorMatch.fromJson(Map<String, dynamic> json) {
    final raw = json['candidates'];
    return ScannedVendorMatch(
      vendorCode: (json['vendorCode']?.toString() ?? '').isEmpty
          ? null
          : json['vendorCode'].toString(),
      vendorName: json['vendorName']?.toString(),
      confidence: _toDouble(json['confidence']) ?? 0,
      matchedOn: json['matchedOn']?.toString(),
      candidates: raw is List
          ? raw
              .whereType<Map>()
              .map((e) => ScannedVendorCandidate.fromJson(
                  e.cast<String, dynamic>()))
              .toList()
          : const [],
    );
  }
}

class ScannedVendorCandidate {
  const ScannedVendorCandidate({
    required this.vendorCode,
    required this.vendorName,
    required this.score,
  });

  final String vendorCode;
  final String vendorName;
  final double score;

  factory ScannedVendorCandidate.fromJson(Map<String, dynamic> json) =>
      ScannedVendorCandidate(
        vendorCode: json['vendorCode']?.toString() ?? '',
        vendorName: json['vendorName']?.toString() ?? '',
        score: _toDouble(json['score']) ?? 0,
      );
}

/// The duplicate-challan rule POST /gate-entries enforces, answered UP FRONT.
///
/// Creating a duplicate challan for the same vendor is rejected with a 409.
/// Finding that out after the guard has reviewed every field is the worst
/// moment — the truck is at the barrier and the work is wasted — so the scan
/// answers it before the form is touched.
///
/// [checked] is false when it could not be answered (no challan number read,
/// or the vendor is unresolved and the rule is per vendor). That is not the
/// same as "not a duplicate", and the UI must not present it as such.
class DuplicateChallanCheck {
  const DuplicateChallanCheck({
    required this.checked,
    required this.isDuplicate,
    this.existingGateEntryId,
    this.existingGateEntryNo,
    this.existingGateMovement,
    this.reason,
  });

  final bool checked;
  final bool isDuplicate;
  final String? existingGateEntryId;
  final String? existingGateEntryNo;
  final String? existingGateMovement;
  final String? reason;

  factory DuplicateChallanCheck.fromJson(Map<String, dynamic> json) =>
      DuplicateChallanCheck(
        checked: json['checked'] as bool? ?? false,
        isDuplicate: json['isDuplicate'] as bool? ?? false,
        existingGateEntryId: json['existingGateEntryId']?.toString(),
        existingGateEntryNo: json['existingGateEntryNo']?.toString(),
        existingGateMovement: json['existingGateMovement']?.toString(),
        reason: json['reason']?.toString(),
      );
}

class ScanWarning {
  const ScanWarning({
    required this.code,
    required this.message,
    this.fields = const [],
  });

  final String code;
  final String message;
  final List<String> fields;

  /// Warnings that mean "the photo itself is the problem" — worth offering a
  /// retake rather than sending the guard to fix fields one by one.
  bool get isPhotoQuality => const {
        'BLURRED_IMAGE',
        'LOW_CONTRAST_IMAGE',
        'LOW_RESOLUTION_IMAGE',
        'NO_TEXT_DETECTED',
        'PDF_HAS_NO_TEXT_LAYER',
      }.contains(code);

  /// Blocking in practice: submitting will be rejected by the API.
  bool get isBlocking => code == 'DUPLICATE_CHALLAN';

  factory ScanWarning.fromJson(Map<String, dynamic> json) {
    final f = json['fields'];
    return ScanWarning(
      code: json['code']?.toString() ?? 'WARNING',
      message: json['message']?.toString() ?? '',
      fields: f is List ? f.map((e) => e.toString()).toList() : const [],
    );
  }
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
