import 'dart:convert';

/// Parsed payload of an Indian GST e-invoice QR (NIC / IRP format).
///
/// The QR content is a JWT signed by the Invoice Registration Portal. The
/// JWT payload looks like:
///   { "data": "<JSON string with the actual fields>", "iss": "NIC" }
/// where the inner JSON has the fields below.
///
/// All fields are nullable because the QR can also legitimately be plain
/// text (just a challan number) — in that case only [docNo] is populated.
class EInvoiceQrData {
  const EInvoiceQrData({
    this.sellerGstin,
    this.buyerGstin,
    this.docNo,
    this.docDateRaw,
    this.docType,
    this.totalInvValue,
    this.itemCount,
    this.mainHsnCode,
    this.irn,
    this.irnDateRaw,
    this.rawInnerJson,
    this.rawOuterJson,
  });

  final String? sellerGstin;
  final String? buyerGstin;
  final String? docNo;
  final String? docDateRaw; // 'DD/MM/YYYY' from NIC
  final String? docType;
  final num? totalInvValue;
  final int? itemCount;
  final String? mainHsnCode;
  final String? irn;
  final String? irnDateRaw;
  /// All fields from the inner JSON (the actual invoice data).
  /// Useful for spotting non-standard keys the parser doesn't know about.
  final Map<String, dynamic>? rawInnerJson;
  /// The JWT payload wrapper (usually `{ "data": "...", "iss": "NIC" }`).
  /// Surfaces JWT-level fields like `iss`, `iat`, `exp` if present.
  final Map<String, dynamic>? rawOuterJson;

  /// Document date converted to ISO 'yyyy-MM-dd' (what our form fields use).
  /// Returns null if [docDateRaw] is missing or unparseable.
  String? get docDateIso {
    final raw = docDateRaw?.trim();
    if (raw == null || raw.isEmpty) return null;
    final m = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})').firstMatch(raw);
    if (m == null) return null;
    final dd = m.group(1)!.padLeft(2, '0');
    final mm = m.group(2)!.padLeft(2, '0');
    final yyyy = m.group(3)!;
    return '$yyyy-$mm-$dd';
  }

  bool get hasAnyData =>
      (docNo ?? '').isNotEmpty ||
      (sellerGstin ?? '').isNotEmpty ||
      (irn ?? '').isNotEmpty;

  /// Best-effort parse of a scanned QR string.
  ///
  /// Tries (in order):
  ///   1. JWT format (header.payload.signature) with a `data` field carrying
  ///      a JSON string — the standard NIC e-invoice format.
  ///   2. Plain JSON with the same field names.
  ///   3. Falls back to treating the raw text as a plain challan number.
  static EInvoiceQrData? tryParse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    final fromJwt = _tryParseJwt(trimmed);
    if (fromJwt != null) return fromJwt;

    final fromJson = _tryParseJson(trimmed);
    if (fromJson != null) return fromJson;

    // Last resort: treat as a plain challan number.
    return EInvoiceQrData(docNo: trimmed);
  }

  static EInvoiceQrData? _tryParseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payloadStr = _base64UrlDecode(parts[1]);
      final payload = jsonDecode(payloadStr);
      if (payload is! Map<String, dynamic>) return null;
      final dataRaw = payload['data'];
      if (dataRaw is String) {
        final inner = jsonDecode(dataRaw);
        if (inner is Map<String, dynamic>) {
          return _fromMap(inner, outer: payload);
        }
      } else if (dataRaw is Map<String, dynamic>) {
        return _fromMap(dataRaw, outer: payload);
      }
      // Some QRs put the fields directly on the payload (no `data` wrapper)
      return _fromMap(payload, outer: null);
    } catch (_) {
      return null;
    }
  }

  static EInvoiceQrData? _tryParseJson(String s) {
    try {
      final decoded = jsonDecode(s);
      if (decoded is Map<String, dynamic>) {
        final inner = decoded['data'];
        if (inner is String) {
          final innerJson = jsonDecode(inner);
          if (innerJson is Map<String, dynamic>) {
            return _fromMap(innerJson, outer: decoded);
          }
        } else if (inner is Map<String, dynamic>) {
          return _fromMap(inner, outer: decoded);
        }
        return _fromMap(decoded, outer: null);
      }
    } catch (_) {
      // not JSON
    }
    return null;
  }

  static EInvoiceQrData _fromMap(
    Map<String, dynamic> m, {
    Map<String, dynamic>? outer,
  }) {
    String? s(String key) {
      final v = m[key];
      if (v == null) return null;
      final str = v.toString().trim();
      return str.isEmpty ? null : str;
    }

    num? n(String key) {
      final v = m[key];
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse(v.toString());
    }

    int? i(String key) {
      final v = m[key];
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return EInvoiceQrData(
      sellerGstin: s('SellerGstin') ?? s('sellerGstin'),
      buyerGstin: s('BuyerGstin') ?? s('buyerGstin'),
      docNo: s('DocNo') ?? s('docNo'),
      docDateRaw: s('DocDt') ?? s('docDt'),
      docType: s('DocTyp') ?? s('docType'),
      totalInvValue: n('TotInvVal') ?? n('totalInvVal'),
      itemCount: i('ItemCnt') ?? i('itemCount'),
      mainHsnCode: s('MainHsnCode') ?? s('mainHsnCode'),
      irn: s('Irn') ?? s('irn'),
      irnDateRaw: s('IrnDt') ?? s('irnDt'),
      rawInnerJson: Map<String, dynamic>.from(m),
      rawOuterJson: outer == null ? null : Map<String, dynamic>.from(outer),
    );
  }

  static String _base64UrlDecode(String input) {
    // base64Url.normalize handles missing padding for us.
    final normalized = base64.normalize(input);
    return utf8.decode(base64Url.decode(normalized));
  }
}
