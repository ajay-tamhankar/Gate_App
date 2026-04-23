import 'package:excel/excel.dart' as xl;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/exception_report_item.dart';
import '../models/report_models.dart';
import 'export_file_helper.dart';


class ReportExportService {
  final ExportFileHelper _fileHelper = getExportFileHelper();

  static final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  String _formatDate(DateTime? value) {
    if (value == null) return '';
    return _dateFormat.format(value.toLocal());
  }

  String _formatTime(DateTime? value) {
    if (value == null) return '';
    return _timeFormat.format(value.toLocal());
  }

  String _formatTurnaroundTime(DateTime gateIn, DateTime? gateOut) {
    if (gateOut == null || gateOut.isBefore(gateIn)) return '';

    final duration = gateOut.difference(gateIn);
    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0 || parts.isEmpty) parts.add('${minutes}m');
    return parts.join(' ');
  }

  Future<void> exportGateEntryRegisterToExcel(
      List<GateEntryReportItem> data) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      xl.TextCellValue('Gate Entry No'),
      xl.TextCellValue('Invoice/Challan Number'),
      xl.TextCellValue('Gate In Date'),
      xl.TextCellValue('Gate In Time'),
      xl.TextCellValue('Gate Out Time'),
      xl.TextCellValue('Turnaround Time'),
      xl.TextCellValue('Vendor'),
      xl.TextCellValue('Vendor Code'),
      xl.TextCellValue('PO Number'),
      xl.TextCellValue('Vehicle No'),
      xl.TextCellValue('LR Number'),
      xl.TextCellValue('Number Boxes (qty)'),
      xl.TextCellValue('Material'),
    ]);

    for (final item in data) {
      sheet.appendRow([
        xl.TextCellValue(item.gateEntryNo),
        xl.TextCellValue(item.challanNo),
        xl.TextCellValue(_formatDate(item.date)),
        xl.TextCellValue(_formatTime(item.date)),
        xl.TextCellValue(_formatTime(item.gateOutDate)),
        xl.TextCellValue(_formatTurnaroundTime(item.date, item.gateOutDate)),
        xl.TextCellValue(item.vendor),
        xl.TextCellValue(item.vendorCode),
        xl.TextCellValue(item.poNumber),
        xl.TextCellValue(item.vehicleNo),
        xl.TextCellValue(item.lrNo),
        xl.IntCellValue(item.qty),
        xl.TextCellValue(item.material),
      ]);
    }

    final fileBytes = excel.encode()!;
    await _fileHelper.saveAndShare(
      fileName: 'GateEntryRegister.xlsx',
      bytes: fileBytes,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  Future<void> exportGateEntryRegisterToPdf(
      List<GateEntryReportItem> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Gate Entry Register',
                  style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8,
                ),
                cellStyle: const pw.TextStyle(fontSize: 7),
                headers: [
                  'Gate Entry No',
                  'Invoice/Challan Number',
                  'Gate In Date',
                  'Gate In Time',
                  'Gate Out Time',
                  'Turnaround Time',
                  'Vendor',
                  'Vendor Code',
                  'PO Number',
                  'Vehicle No',
                  'LR Number',
                  'Number Boxes (qty)',
                  'Material',
                ],
                data: data
                    .map((item) => [
                          item.gateEntryNo,
                          item.challanNo,
                          _formatDate(item.date),
                          _formatTime(item.date),
                          _formatTime(item.gateOutDate),
                          _formatTurnaroundTime(item.date, item.gateOutDate),
                          item.vendor,
                          item.vendorCode,
                          item.poNumber,
                          item.vehicleNo,
                          item.lrNo,
                          item.qty.toString(),
                          item.material,
                        ])
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    await _fileHelper.saveAndShare(
      fileName: 'GateEntryRegister.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
    );
  }

  // GRN RECONCILIATION
  Future<void> exportGrnReconReportToExcel(
      List<GrnReconReportItem> data) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      xl.TextCellValue('Gate Entry No'),
      xl.TextCellValue('GRN No'),
      xl.TextCellValue('PO No'),
      xl.TextCellValue('Challan No'),
      xl.TextCellValue('Matched Status'),
      xl.TextCellValue('Qty Diff'),
      xl.TextCellValue('Vendor Name'),
      xl.TextCellValue('Reconciled At'),
      xl.TextCellValue('Sr No'),
      xl.TextCellValue('Remarks'),
      xl.TextCellValue('Duplicate Reference'),
      xl.TextCellValue('Dublicate'),
      xl.TextCellValue('Reference No'),
      xl.TextCellValue('Reference'),
      xl.TextCellValue('Document Date'),
      xl.TextCellValue('Quantity'),
      xl.TextCellValue('Material'),
      xl.TextCellValue('Material Document'),
      xl.TextCellValue('Posting Date'),
      xl.TextCellValue('Plant'),
      xl.TextCellValue('Material Description'),
      xl.TextCellValue('Movement Type'),
      xl.TextCellValue('Movement Type Text'),
      xl.TextCellValue('Supplier'),
      xl.TextCellValue('Purchase Order'),
      xl.TextCellValue('Document Header Text'),
      xl.TextCellValue('User Name'),
      xl.TextCellValue('Entry Date'),
      xl.TextCellValue('Time Of Entry'),
      xl.TextCellValue('Amount In Local Currency'),
      xl.TextCellValue('Qty In Opun'),
      xl.TextCellValue('Qty In Order Unit'),
      xl.TextCellValue('Local Time'),
      xl.TextCellValue('Local Date'),
      xl.TextCellValue('Shift'),
      xl.TextCellValue('Store Remarks'),
      xl.TextCellValue('Status'),
      xl.TextCellValue('Aging'),
      xl.TextCellValue('MDR'),
      xl.TextCellValue('Scanning Invoice Status'),
      xl.TextCellValue('Scanning Date'),
      xl.TextCellValue('Vendor'),
      xl.TextCellValue('Source Vendor Name'),
      xl.TextCellValue('Buyer Name'),
      xl.TextCellValue('Maker Checker'),
    ]);

    for (final item in data) {
      sheet.appendRow([
        xl.TextCellValue(item.gateEntryNo ?? ''),
        xl.TextCellValue(item.grnNo ?? ''),
        xl.TextCellValue(item.poNumber ?? ''),
        xl.TextCellValue(item.challanNo ?? ''),
        xl.TextCellValue(item.matchedStatus ?? ''),
        xl.TextCellValue(item.quantityDiff?.toString() ?? ''),
        xl.TextCellValue(item.vendorName ?? ''),
        xl.TextCellValue(item.reconciledAt ?? ''),
        xl.TextCellValue(item.srNo ?? ''),
        xl.TextCellValue(item.remarks ?? ''),
        xl.TextCellValue(item.duplicateReference ?? ''),
        xl.TextCellValue(item.dublicate ?? ''),
        xl.TextCellValue(item.referenceNo ?? ''),
        xl.TextCellValue(item.reference ?? ''),
        xl.TextCellValue(item.documentDate ?? ''),
        xl.TextCellValue(item.quantity ?? ''),
        xl.TextCellValue(item.material ?? ''),
        xl.TextCellValue(item.materialDocument ?? ''),
        xl.TextCellValue(item.postingDate ?? ''),
        xl.TextCellValue(item.plant ?? ''),
        xl.TextCellValue(item.materialDescription ?? ''),
        xl.TextCellValue(item.movementType ?? ''),
        xl.TextCellValue(item.movementTypeText ?? ''),
        xl.TextCellValue(item.supplier ?? ''),
        xl.TextCellValue(item.purchaseOrder ?? ''),
        xl.TextCellValue(item.documentHeaderText ?? ''),
        xl.TextCellValue(item.userName ?? ''),
        xl.TextCellValue(item.entryDate ?? ''),
        xl.TextCellValue(item.timeOfEntry ?? ''),
        xl.TextCellValue(item.amountInLocalCurrency ?? ''),
        xl.TextCellValue(item.qtyInOpun ?? ''),
        xl.TextCellValue(item.qtyInOrderUnit ?? ''),
        xl.TextCellValue(item.localTime ?? ''),
        xl.TextCellValue(item.localDate ?? ''),
        xl.TextCellValue(item.shift ?? ''),
        xl.TextCellValue(item.storeRemarks ?? ''),
        xl.TextCellValue(item.status ?? ''),
        xl.TextCellValue(item.aging ?? ''),
        xl.TextCellValue(item.mdr ?? ''),
        xl.TextCellValue(item.scanningInvoiceStatus ?? ''),
        xl.TextCellValue(item.scanningDate ?? ''),
        xl.TextCellValue(item.vendor ?? ''),
        xl.TextCellValue(item.sourceVendorName ?? ''),
        xl.TextCellValue(item.buyerName ?? ''),
        xl.TextCellValue(item.makerChecker ?? ''),
      ]);
    }

    final fileBytes = excel.encode()!;
    await _fileHelper.saveAndShare(
      fileName: 'GRN_Reconciliation.xlsx',
      bytes: fileBytes,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  Future<void> exportGrnReconReportToPdf(List<GrnReconReportItem> data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('GRN Reconciliation Report',
                  style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: [
                  'Entry No',
                  'GRN',
                  'PO',
                  'Challan',
                  'Match Status',
                  'Diff'
                ],
                data: data
                    .map((item) => [
                          item.gateEntryNo ?? '',
                          item.grnNo ?? '',
                          item.poNumber ?? '',
                          item.challanNo ?? '',
                          item.matchedStatus ?? '',
                          item.quantityDiff?.toString() ?? ''
                        ])
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
    final bytes = await pdf.save();
    await _fileHelper.saveAndShare(
      fileName: 'GRN_Reconciliation.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
    );
  }

  // PENDING GRN
  Future<void> exportPendingGrnReportToExcel(
      List<PendingGrnReportItem> data) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Sheet1'];
    sheet.appendRow([
      xl.TextCellValue('Gate Entry No'),
      xl.TextCellValue('PO Number'),
      xl.TextCellValue('Vendor'),
      xl.TextCellValue('Material'),
      xl.TextCellValue('Days Pending')
    ]);
    for (final item in data) {
      sheet.appendRow([
        xl.TextCellValue(item.gateEntryNo),
        xl.TextCellValue(item.poNumber),
        xl.TextCellValue(item.vendor),
        xl.TextCellValue(item.material),
        xl.TextCellValue(item.daysPending.toString())
      ]);
    }
    final fileBytes = excel.encode()!;
    await _fileHelper.saveAndShare(
      fileName: 'Pending_GRN.xlsx',
      bytes: fileBytes,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  Future<void> exportPendingGrnReportToPdf(
      List<PendingGrnReportItem> data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Pending GRN Report',
              style: const pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          // ignore: deprecated_member_use
          pw.Table.fromTextArray(
            headers: ['Entry No', 'PO', 'Vendor', 'Material', 'Days Pending'],
            data: data
                .map((item) => [
                      item.gateEntryNo,
                      item.poNumber,
                      item.vendor,
                      item.material,
                      item.daysPending
                    ])
                .toList(),
          ),
        ],
      ),
    ));
    final bytes = await pdf.save();
    await _fileHelper.saveAndShare(
      fileName: 'Pending_GRN.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
    );
  }

  // AUDIT TRAIL
  Future<void> exportAuditTrailReportToExcel(
      List<AuditTrailReportItem> data) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Sheet1'];
    sheet.appendRow([
      xl.TextCellValue('Date'),
      xl.TextCellValue('User'),
      xl.TextCellValue('Action'),
      xl.TextCellValue('Entity'),
      xl.TextCellValue('Changes')
    ]);
    for (final item in data) {
      sheet.appendRow([
        xl.TextCellValue(item.date.toIso8601String()),
        xl.TextCellValue(item.user),
        xl.TextCellValue(item.action),
        xl.TextCellValue(item.entity),
        xl.TextCellValue(item.changes)
      ]);
    }
    final fileBytes = excel.encode()!;
    await _fileHelper.saveAndShare(
      fileName: 'Audit_Trail.xlsx',
      bytes: fileBytes,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  Future<void> exportAuditTrailReportToPdf(
      List<AuditTrailReportItem> data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Audit Trail Report',
              style: const pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          // ignore: deprecated_member_use
          pw.Table.fromTextArray(
            headers: ['Date', 'User', 'Action', 'Entity', 'Changes'],
            data: data
                .map((item) => [
                      item.date.toString().substring(0, 19),
                      item.user,
                      item.action,
                      item.entity,
                      item.changes
                    ])
                .toList(),
          ),
        ],
      ),
    ));
    final bytes = await pdf.save();
    await _fileHelper.saveAndShare(
      fileName: 'Audit_Trail.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
    );
  }

  // EXCEPTION REPORT
  Future<void> exportExceptionReportToExcel(
      List<ExceptionReportItem> data) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Sheet1'];
    sheet.appendRow([
      xl.TextCellValue('Exception ID'),
      xl.TextCellValue('Gate Entry ID'),
      xl.TextCellValue('PO Number'),
      xl.TextCellValue('Status'),
      xl.TextCellValue('Description'),
      xl.TextCellValue('Created At'),
    ]);
    for (final item in data) {
      sheet.appendRow([
        xl.TextCellValue(item.id),
        xl.TextCellValue(item.gateEntryId),
        xl.TextCellValue(item.poNumber),
        xl.TextCellValue(item.status),
        xl.TextCellValue(item.description),
        xl.TextCellValue(item.createdAt.toIso8601String()),
      ]);
    }
    final fileBytes = excel.encode()!;
    await _fileHelper.saveAndShare(
      fileName: 'Exception_Report.xlsx',
      bytes: fileBytes,
      mimeType:
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  Future<void> exportExceptionReportToPdf(
      List<ExceptionReportItem> data) async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Exception Report',
              style: const pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          // ignore: deprecated_member_use
          pw.Table.fromTextArray(
            headers: [
              'Exception ID',
              'Gate Entry ID',
              'PO',
              'Status',
              'Description',
              'Created'
            ],
            data: data
                .map((item) => [
                      item.id,
                      item.gateEntryId,
                      item.poNumber,
                      item.status,
                      item.description,
                      item.createdAt.toString().substring(0, 19),
                    ])
                .toList(),
          ),
        ],
      ),
    ));
    final bytes = await pdf.save();
    await _fileHelper.saveAndShare(
      fileName: 'Exception_Report.pdf',
      bytes: bytes,
      mimeType: 'application/pdf',
    );
  }
}

