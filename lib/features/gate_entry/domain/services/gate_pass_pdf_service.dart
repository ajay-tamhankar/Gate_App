import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/gate_entry.dart';
import '../models/gate_entry_item.dart';

class GatePassPdfService {
  static final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  Future<void> printGatePass(GateEntry entry) async {
    final doc = await _buildDocument(entry);
    await Printing.layoutPdf(
      name: _fileName(entry),
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Future<pw.Document> _buildDocument(GateEntry entry) async {
    final doc = pw.Document();
    final isInward = entry.gateMovement == GateMovement.inMovement;
    final title = isInward ? 'GATE PASS INWARD' : 'GATE PASS OUTWARD';
    final footerLabel = isInward ? 'Security' : 'Authorised Signatory';

    final gatePassNo = (entry.gateEntryNo ?? '').trim().isNotEmpty
        ? entry.gateEntryNo!.trim()
        : entry.id;
    final dateText = entry.gateTimestamp != null
        ? _dateFormat.format(entry.gateTimestamp!.toLocal())
        : _dateFormat.format(DateTime.now());
    final descriptionLines = _buildDescriptionLines(entry.items);
    final challanLine = entry.challanNo.trim();
    final vehicleAndLr = _buildVehicleAndLr(entry);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildTitleBar(title),
              _buildGatePassHeaderRow(gatePassNo: gatePassNo, date: dateText),
              _buildAddressAndMsRow(entry.vendorName),
              _buildLabeledBlock(
                label: 'D.C. / Inv. No.',
                content: challanLine.isEmpty ? '' : challanLine,
                minHeight: 36,
              ),
              _buildLabeledBlock(
                label: 'Description of Goods :-',
                content: descriptionLines.join('\n'),
                minHeight: 140,
              ),
              _buildFooterRow(
                vehicleAndLr: vehicleAndLr,
                footerLabel: footerLabel,
              ),
            ],
          );
        },
      ),
    );

    return doc;
  }

  pw.Widget _buildTitleBar(String title) {
    return pw.Container(
      width: double.infinity,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1),
      ),
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Center(
        child: pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  pw.Widget _buildGatePassHeaderRow({
    required String gatePassNo,
    required String date,
  }) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(width: 1),
          right: pw.BorderSide(width: 1),
          bottom: pw.BorderSide(width: 1),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(width: 1)),
              ),
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'Gate Pass No :- ',
                      style:
                          pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.TextSpan(text: gatePassNo),
                  ],
                ),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'Date :- ',
                      style:
                          pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.TextSpan(text: date),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildAddressAndMsRow(String vendorName) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(width: 1),
          right: pw.BorderSide(width: 1),
          bottom: pw.BorderSide(width: 1),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: const pw.BoxDecoration(
                border: pw.Border(right: pw.BorderSide(width: 1)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Schwing Stetter India Pvt Ltd',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('C/o Bhoir Dredging Co Pvt Ltd,',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Bhoir Compound ,CS-20, Ghodbunder,',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text(' Behind Velkar Petrol Pump,',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('Thane, Village-Versova,',
                      style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('MAHARSHTRA - 401104.',
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('M/S :-',
                      style:
                          pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  _underlinedLine(vendorName),
                  pw.SizedBox(height: 14),
                  _underlinedLine(''),
                  pw.SizedBox(height: 14),
                  _underlinedLine(''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _underlinedLine(String text) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(width: 0.7)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  pw.Widget _buildLabeledBlock({
    required String label,
    required String content,
    required double minHeight,
  }) {
    return pw.Container(
      width: double.infinity,
      constraints: pw.BoxConstraints(minHeight: minHeight),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(width: 1),
          right: pw.BorderSide(width: 1),
          bottom: pw.BorderSide(width: 1),
        ),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          if (content.trim().isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(content, style: const pw.TextStyle(fontSize: 10)),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildFooterRow({
    required String vehicleAndLr,
    required String footerLabel,
  }) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          left: pw.BorderSide(width: 1),
          right: pw.BorderSide(width: 1),
          bottom: pw.BorderSide(width: 1),
        ),
      ),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    text: 'Vehicle & LR no :- ',
                    style:
                        pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: vehicleAndLr),
                ],
              ),
            ),
          ),
          pw.Text(
            footerLabel,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<String> _buildDescriptionLines(List<GateEntryItem> items) {
    if (items.isEmpty) return const [];
    return items.map((item) {
      final parts = <String>[];
      if (item.materialCode.trim().isNotEmpty) {
        parts.add(item.materialCode.trim());
      }
      parts.add('Qty: ${item.challanQty} ${item.uom}'.trim());
      if (item.poNumber.trim().isNotEmpty) {
        parts.add('PO: ${item.poNumber.trim()}');
      }
      return parts.join('  |  ');
    }).toList();
  }

  String _buildVehicleAndLr(GateEntry entry) {
    final vehicle = entry.vehicleNo.trim();
    final lr = entry.lrNumber.trim();
    if (vehicle.isEmpty && lr.isEmpty) return '';
    if (vehicle.isEmpty) return lr;
    if (lr.isEmpty) return vehicle;
    return '$vehicle / $lr';
  }

  String _fileName(GateEntry entry) {
    final ref = (entry.gateEntryNo ?? '').trim().isNotEmpty
        ? entry.gateEntryNo!.trim()
        : entry.id;
    final safe = ref.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return 'gate_pass_$safe.pdf';
  }
}

final gatePassPdfService = GatePassPdfService();
