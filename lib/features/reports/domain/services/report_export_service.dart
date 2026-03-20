import 'package:excel/excel.dart' as xl;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/exception_report_item.dart';
import '../models/report_models.dart';
import 'export_file_helper.dart';


class ReportExportService {
  final ExportFileHelper _fileHelper = getExportFileHelper();
  Future<void> exportGateEntryRegisterToExcel(
      List<GateEntryReportItem> data) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      xl.TextCellValue('Gate Entry No'),
      xl.TextCellValue('Date'),
      xl.TextCellValue('Vendor'),
      xl.TextCellValue('PO Number'),
      xl.TextCellValue('Vehicle No'),
      xl.TextCellValue('Material'),
      xl.TextCellValue('Status'),
    ]);

    for (final item in data) {
      sheet.appendRow([
        xl.TextCellValue(item.gateEntryNo),
        xl.TextCellValue(item.date.toIso8601String()),
        xl.TextCellValue(item.vendor),
        xl.TextCellValue(item.poNumber),
        xl.TextCellValue(item.vehicleNo),
        xl.TextCellValue(item.material),
        xl.TextCellValue(item.status),
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
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Gate Entry Register',
                  style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                headers: [
                  'Entry No',
                  'Date',
                  'Vendor',
                  'PO',
                  'Vehicle',
                  'Material',
                  'Status'
                ],
                data: data
                    .map((item) => [
                          item.gateEntryNo,
                          item.date.toString().substring(0, 10),
                          item.vendor,
                          item.poNumber,
                          item.vehicleNo,
                          item.material,
                          item.status
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
      xl.TextCellValue('PO Number'),
      xl.TextCellValue('Challan No'),
      xl.TextCellValue('Matched Status'),
      xl.TextCellValue('Qty Difference'),
    ]);

    for (final item in data) {
      sheet.appendRow([
        xl.TextCellValue(item.gateEntryNo),
        xl.TextCellValue(item.grnNo),
        xl.TextCellValue(item.poNumber),
        xl.TextCellValue(item.challanNo),
        xl.TextCellValue(item.matchedStatus),
        xl.TextCellValue(item.quantityDiff.toString()),
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
                          item.gateEntryNo,
                          item.grnNo,
                          item.poNumber,
                          item.challanNo,
                          item.matchedStatus,
                          item.quantityDiff
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

