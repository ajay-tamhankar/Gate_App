import 'package:flutter/material.dart';

import '../../domain/models/scanned_document.dart';

/// Confirmation step between reading a challan and filling the form.
///
/// This sheet is the whole reason scan-to-autofill is safe to ship. The
/// backend returns a confidence per field and a `needsReview` flag, and if
/// the app quietly poured those values into the form the feature would trade
/// typing errors for something worse: a wrong value nobody looked at, saved
/// with the same confidence as a correct one. An empty box gets typed
/// correctly; a wrong prefilled box gets submitted.
///
/// So every scan surfaces here first. Confident fields are shown ticked and
/// collapsed out of the way; flagged fields are shown with what was read,
/// where it came from, and any runner-up readings as one-tap alternatives.
/// The guard applies the lot with one action, having actually seen it.
class ScanReviewSheet extends StatefulWidget {
  const ScanReviewSheet({
    super.key,
    required this.scan,
    this.onRetake,
  });

  final ScannedDocument scan;

  /// Offered when the photo itself is the problem — a retake fixes more than
  /// correcting six fields by hand does.
  final VoidCallback? onRetake;

  /// Returns the values the guard accepted, or null if they cancelled.
  /// Alternatives chosen in the sheet are already substituted in.
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required ScannedDocument scan,
    VoidCallback? onRetake,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ScanReviewSheet(scan: scan, onRetake: onRetake),
    );
  }

  @override
  State<ScanReviewSheet> createState() => _ScanReviewSheetState();
}

class _ScanReviewSheetState extends State<ScanReviewSheet> {
  /// Working copy — an alternative picked here replaces the read value.
  late final Map<String, dynamic> _values;

  /// Fields the guard has explicitly dropped, so a bad reading can be cleared
  /// without cancelling the whole scan.
  final Set<String> _discarded = {};

  @override
  void initState() {
    super.initState();
    _values = Map<String, dynamic>.of(widget.scan.headerFields);
  }

  /// Human labels for the API's field names. Anything unmapped falls back to
  /// the raw key rather than being hidden — a field we forgot to label is
  /// still a field the guard should see.
  static const _labels = <String, String>{
    'challanNo': 'Challan number',
    'documentDate': 'Document date',
    'vendorCode': 'Vendor code',
    'vendorName': 'Vendor name',
    'vehicleNo': 'Vehicle number',
    'transporterName': 'Transporter',
    'lrNumber': 'LR number',
    'driverContactNo': 'Driver contact',
    'gateMovement': 'Direction',
    'gstin': 'GSTIN',
    'poNumber': 'PO number',
    'invoiceNo': 'Invoice number',
    'ewayBillNo': 'E-way bill number',
  };

  static const _verifiedLabels = <String, String>{
    'checksum': 'checksum verified',
    'tax-arithmetic': 'totals add up',
    'amount-in-words': 'matches amount in words',
    'trip-vehicle': 'matches the trip vehicle',
    'gstin-embedded-pan': 'from the verified GSTIN',
    'ifsc-bank-code': 'from the verified IFSC',
  };

  String _label(String key) => _labels[key] ?? key;

  bool _needsReview(String key) =>
      widget.scan.review[key]?.needsReview ?? false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scan = widget.scan;

    // Only fields that were actually READ are shown. A draft key with no
    // review entry did not come off the paper — `gateMovement` is injected by
    // the server because the app already knows the direction — and listing it
    // as "read clearly" would claim the scanner found something it never
    // looked for. It still rides along in the applied map so the draft stays
    // submittable; it simply is not presented as a scan result.
    final keys = _values.keys.where(widget.scan.review.containsKey).toList()
      // Flagged fields first: they are the only ones that need attention, and
      // burying them under the confident ones is how they get skipped.
      ..sort((a, b) {
        final fa = _needsReview(a) ? 0 : 1;
        final fb = _needsReview(b) ? 0 : 1;
        if (fa != fb) return fa - fb;
        return _label(a).compareTo(_label(b));
      });

    final flagged = keys.where(_needsReview).toList();
    final confident = keys.where((k) => !_needsReview(k)).toList();
    final photoProblem = scan.warnings.where((w) => w.isPhotoQuality).toList();
    final blocking = scan.warnings.where((w) => w.isBlocking).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          _handle(theme),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _header(theme, scan),
                const SizedBox(height: 12),

                // Blocking first. A duplicate challan means POST
                // /gate-entries will reject this, so saying it before the
                // guard reviews fields saves the whole exercise.
                for (final w in blocking) _blockingBanner(theme, w),
                for (final w in photoProblem) _photoBanner(theme, w),

                if (!scan.hasDraft) _nothingRead(theme, scan),

                if (flagged.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _sectionLabel(theme, 'Check these ${flagged.length}',
                      'Read with low confidence — confirm before saving.'),
                  for (final key in flagged) _fieldTile(theme, key, flagged: true),
                ],

                if (confident.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _sectionLabel(theme, 'Read clearly (${confident.length})',
                      'Verified or high confidence.'),
                  for (final key in confident) _fieldTile(theme, key, flagged: false),
                ],

                if (scan.items.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _sectionLabel(theme, 'Line items (${scan.items.length})',
                      'Quantities are cross-checked against rate x amount where the invoice prints both.'),
                  for (final item in scan.items) _itemTile(theme, item),
                ],

                // Non-field warnings the guard should still see.
                for (final w in scan.warnings
                    .where((w) => !w.isPhotoQuality && !w.isBlocking))
                  _infoNote(theme, w),
              ],
            ),
          ),
          _actions(theme, scan),
        ],
      ),
    );
  }

  Widget _handle(ThemeData theme) => Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.dividerColor,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _header(ThemeData theme, ScannedDocument scan) {
    // A digital PDF's text layer is exact rather than recognised. Saying so
    // tells the guard there is nothing to double-check, which is true.
    final exact = scan.engine == 'pdf-text';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(exact ? Icons.verified_outlined : Icons.document_scanner_outlined,
            color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Check what was read',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                exact
                    ? 'Read from the PDF text — exact, no guessing involved.'
                    : 'Read from the photo. Anything uncertain is flagged below.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.hintColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(ThemeData theme, String title, String subtitle) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(subtitle,
                style:
                    theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
          ],
        ),
      );

  Widget _fieldTile(ThemeData theme, String key, {required bool flagged}) {
    final review = widget.scan.review[key];
    final value = _values[key];
    final discarded = _discarded.contains(key);
    final verified = review?.verifiedBy ?? const <String>[];

    return Opacity(
      opacity: discarded ? 0.45 : 1,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: flagged
            ? theme.colorScheme.errorContainer.withValues(alpha: 0.18)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    flagged
                        ? Icons.error_outline
                        : (verified.isNotEmpty
                            ? Icons.verified_outlined
                            : Icons.check_circle_outline),
                    size: 18,
                    color: flagged
                        ? theme.colorScheme.error
                        : Colors.green.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_label(key),
                        style: theme.textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: discarded ? 'Use this value' : 'Do not use',
                    icon: Icon(
                        discarded ? Icons.undo : Icons.close,
                        size: 18),
                    onPressed: () => setState(() {
                      if (discarded) {
                        _discarded.remove(key);
                      } else {
                        _discarded.add(key);
                      }
                    }),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      value == null || value.toString().isEmpty
                          ? '—'
                          : value.toString(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration:
                            discarded ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (verified.isNotEmpty)
                      Text(
                        verified
                            .map((v) => _verifiedLabels[v] ?? v)
                            .join(' · '),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.green.shade700),
                      )
                    else if (flagged && review?.source != null)
                      // Telling the guard WHERE it came from is more useful
                      // than a bare percentage — it says where to look on the
                      // paper to check it.
                      Text(_sourceHint(review!),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor)),
                    if (review?.note != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(review!.note!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: theme.colorScheme.error)),
                      ),
                    if ((review?.alternatives ?? const []).isNotEmpty)
                      _alternatives(theme, key, review!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _sourceHint(ScannedFieldReview review) {
    final source = review.source ?? '';
    if (source.startsWith('label:')) {
      return 'Read next to "${source.substring(6)}"';
    }
    if (source == 'shape') return 'Recognised by its format, with no label nearby';
    if (source == 'geometry') return 'Taken from the letterhead';
    if (source == 'vendor-master') return review.reason ?? 'Matched in vendor master';
    if (source.startsWith('derived:')) {
      return 'Copied from the ${_label(source.substring(8))}';
    }
    return review.reason ?? '';
  }

  /// Runner-up readings as one-tap choices. When a field is wrong the correct
  /// value is usually the second candidate, so this turns a correction into a
  /// tap instead of typing on a phone at a barrier.
  Widget _alternatives(ThemeData theme, String key, ScannedFieldReview review) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final alt in review.alternatives)
            ActionChip(
              visualDensity: VisualDensity.compact,
              label: Text(_altLabel(alt), style: theme.textTheme.bodySmall),
              onPressed: () => setState(() {
                final picked = _altValue(alt);
                if (picked != null) _values[key] = picked;
                // Picking an alternative for the vendor must carry its NAME
                // across too, or the form shows a code with a stale name.
                if (key == 'vendorCode' && alt['vendorName'] != null) {
                  _values['vendorName'] = alt['vendorName'];
                }
                _discarded.remove(key);
              }),
            ),
        ],
      ),
    );
  }

  // Alternatives are heterogeneous: vendor candidates carry a code and name,
  // ordinary field alternatives carry a value.
  String _altLabel(Map<String, dynamic> alt) {
    if (alt['vendorCode'] != null) {
      final name = (alt['vendorName'] ?? '').toString();
      return name.isEmpty
          ? alt['vendorCode'].toString()
          : '${alt['vendorCode']} · $name';
    }
    return (alt['value'] ?? '').toString();
  }

  dynamic _altValue(Map<String, dynamic> alt) =>
      alt['vendorCode'] ?? alt['value'];

  Widget _itemTile(ThemeData theme, Map<String, dynamic> item) {
    final parts = <String>[
      if ((item['materialCode'] ?? '').toString().isNotEmpty)
        item['materialCode'].toString(),
      if ((item['materialDescription'] ?? '').toString().isNotEmpty)
        item['materialDescription'].toString(),
    ];
    final qty = item['challanQty'];
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.inventory_2_outlined, size: 18),
      title: Text(parts.isEmpty ? '(no description)' : parts.join(' — '),
          style: theme.textTheme.bodyMedium),
      subtitle: (item['poNumber'] ?? '').toString().isEmpty
          ? null
          : Text('PO ${item['poNumber']}',
              style: theme.textTheme.bodySmall),
      trailing: qty == null
          ? null
          : Text('$qty ${item['uom'] ?? ''}'.trim(),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
    );
  }

  Widget _blockingBanner(ThemeData theme, ScanWarning w) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.block, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(w.message,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  Widget _photoBanner(ThemeData theme, ScanWarning w) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.photo_camera_outlined,
                color: Colors.orange, size: 20),
            const SizedBox(width: 10),
            Expanded(
                child: Text(w.message, style: theme.textTheme.bodySmall)),
            if (widget.onRetake != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onRetake!();
                },
                child: const Text('Retake'),
              ),
          ],
        ),
      );

  Widget _infoNote(ThemeData theme, ScanWarning w) => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 16, color: theme.hintColor),
            const SizedBox(width: 8),
            Expanded(
                child: Text(w.message,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor))),
          ],
        ),
      );

  Widget _nothingRead(ThemeData theme, ScannedDocument scan) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.text_snippet_outlined, size: 40, color: theme.hintColor),
            const SizedBox(height: 8),
            Text('Nothing could be read from this document',
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              scan.pageConfidence == null
                  ? 'Enter the gate entry manually.'
                  : 'Legibility scored ${scan.pageConfidence!.round()}%. Retake the photo square-on in even light, or enter the entry manually.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.hintColor),
            ),
          ],
        ),
      );

  Widget _actions(ThemeData theme, ScannedDocument scan) {
    // Counts only fields read from the document, matching what the guard can
    // actually see and drop in this sheet.
    final applying = _values.keys
        .where((k) => scan.review.containsKey(k) && !_discarded.contains(k))
        .length;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            if (widget.onRetake != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onRetake!();
                  },
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('Retake'),
                ),
              ),
            if (widget.onRetake != null) const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: !scan.hasDraft || applying == 0
                    ? null
                    : () {
                        final out = <String, dynamic>{};
                        _values.forEach((k, v) {
                          if (!_discarded.contains(k)) out[k] = v;
                        });
                        if (scan.items.isNotEmpty) out['items'] = scan.items;
                        Navigator.of(context).pop(out);
                      },
                icon: const Icon(Icons.edit_note, size: 18),
                label: Text(applying == 0
                    ? 'Nothing to fill'
                    : 'Fill $applying field${applying == 1 ? '' : 's'}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
