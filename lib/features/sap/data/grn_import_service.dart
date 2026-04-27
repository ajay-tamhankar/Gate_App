import 'dart:convert';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reconciliation/data/sap_grn_repository_impl.dart';
import '../../reconciliation/domain/models/grn_import_models.dart';

/// Service responsible for uploading a GRN import file to the API endpoint.
class GrnImportService {
  GrnImportService(this._repository);

  final SapGrnRepository _repository;
  static const int _maxWebXlsxSizeBytes = 2 * 1024 * 1024;

  static const List<String> _requiredHeaders = [
    'poNumber',
    'materialCode',
    'grnNumber',
    'postingDate',
    'grnQty',
  ];
  static const Map<String, String> _headerAliases = {
    'ponumber': 'poNumber',
    'purchaseorder': 'poNumber',
    'purchaseorderno': 'poNumber',
    'materialcode': 'materialCode',
    'material': 'materialCode',
    'grnnumber': 'grnNumber',
    'grnno': 'grnNumber',
    'materialdocument': 'grnNumber',
    'materialdocumentnumber': 'grnNumber',
    'postingdate': 'postingDate',
    'grndate': 'postingDate',
    'grnqty': 'grnQty',
    'quantity': 'grnQty',
    'qty': 'grnQty',
    'challanno': 'challanNo',
    'reference': 'challanNo',
    'vendorcode': 'vendorCode',
    'supplier': 'vendorCode',
    'vendorname': 'vendorName',
    'localdate': 'localDate',
  };

  /// Uploads [file] to POST /sap/grns/import and always runs full reconciliation.
  Future<GrnImportResult?> importGrn(PlatformFile file) async {
    if (!_isSupportedFile(file.name)) {
      throw GrnImportException('Only CSV and XLSX files are supported.');
    }

    final normalizedName = file.name.toLowerCase();
    if (kIsWeb &&
        normalizedName.endsWith('.xlsx') &&
        file.size > _maxWebXlsxSizeBytes) {
      throw GrnImportException(
        'This XLSX file is too large to process on web. Please use CSV or a smaller XLSX file.',
      );
    }

    try {
      final fileName = file.name;
      List<int>? bytes;
      String? filePath;

      if (normalizedName.endsWith('.csv')) {
        final csvBytes = await _readFileBytes(file);
        final csvContent = utf8.decode(csvBytes, allowMalformed: true);
        final normalizedCsv = _normalizeCsvContent(csvContent);
        _validateCsvHeaders(normalizedCsv);
        bytes = utf8.encode(normalizedCsv);
        filePath = null;
      } else {
        // XLSX handling
        final excelBytes = await _readFileBytes(file);
        if (kIsWeb) {
          await Future<void>.delayed(Duration.zero);
        }
        final csvContent = _convertXlsxToCsv(excelBytes);
        _validateCsvHeaders(csvContent);
        bytes = utf8.encode(csvContent);
      }

      final response = await _repository.importGrns(
        fileName: normalizedName.endsWith('.xlsx')
            ? fileName.replaceAll(RegExp(r'\.xlsx$', caseSensitive: false), '.csv')
            : fileName,
        bytes: bytes,
        filePath: filePath,
      );

      if (!response.success) {
        throw GrnImportException(response.message);
      }

      return response.data;
    } catch (e) {
      if (e is GrnImportException) rethrow;
      throw GrnImportException(e.toString());
    }
  }

  Future<List<int>> _readFileBytes(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes != null) {
      return bytes;
    }

    final path = file.path;
    final stream = file.readStream;
    if (stream != null) {
      final chunks = await stream.toList();
      return chunks.expand((chunk) => chunk).toList();
    }

    if (path == null) {
      throw GrnImportException('Could not determine file path.');
    }

    throw GrnImportException('Could not read file bytes.');
  }

  String _convertXlsxToCsv(List<int> bytes) {
    try {
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        throw GrnImportException('The XLSX file does not contain any sheets.');
      }

      final sheet = excel.tables.values.first;
      if (sheet.rows.isEmpty) {
        throw GrnImportException('The XLSX file is empty.');
      }

      final rawRows = sheet.rows
          .map(
            (row) => _trimTrailingEmptyColumns(
              row.map((cell) => _cellToString(cell?.value)).toList(),
            ),
          )
          .where((row) => row.any((cell) => cell.isNotEmpty))
          .toList();

      if (rawRows.isEmpty) {
        throw GrnImportException('The XLSX file is empty.');
      }

      final headerMatch = _findHeaderRow(rawRows);
      final normalizedRows = <List<String>>[_requiredHeaders];

      for (var rowIndex = headerMatch.rowIndex + 1;
          rowIndex < rawRows.length;
          rowIndex++) {
        final row = rawRows[rowIndex];
        if (_isDescriptiveRow(row)) {
          continue;
        }

        final normalizedRow = _requiredHeaders
            .map(
              (header) => _normalizeValue(
                header,
                _readCell(row, headerMatch.columns[header]),
              ),
            )
            .toList();

        if (normalizedRow.any((value) => value.isNotEmpty)) {
          normalizedRows.add(normalizedRow);
        }
      }

      if (normalizedRows.length == 1) {
        throw GrnImportException(
          'The XLSX file does not contain any GRN rows after the header.',
        );
      }

      return normalizedRows
          .map((row) => row.map(_escapeCsv).join(','))
          .join('\n');
    } catch (e) {
      if (e is GrnImportException) rethrow;
      throw GrnImportException('Failed to read XLSX file.');
    }
  }

  String _cellToString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _escapeCsv(String value) {
    final needsQuotes =
        value.contains(',') || value.contains('"') || value.contains('\n');
    final escaped = value.replaceAll('"', '""');
    return needsQuotes ? '"$escaped"' : escaped;
  }

  bool _isSupportedFile(String fileName) {
    final normalized = fileName.toLowerCase();
    return normalized.endsWith('.csv') || normalized.endsWith('.xlsx');
  }

  String _normalizeCsvContent(String csvContent) {
    final lines = const LineSplitter().convert(csvContent);
    final rawRows = lines
        .map(_parseCsvLine)
        .map(_trimTrailingEmptyColumns)
        .where((row) => row.any((cell) => cell.trim().isNotEmpty))
        .toList();

    if (rawRows.isEmpty) {
      throw GrnImportException(
        'The import file is empty. Required columns: ${_requiredHeaders.join(', ')}.',
      );
    }

    final headerMatch = _findHeaderRow(rawRows);
    final normalizedRows = <List<String>>[_requiredHeaders];

    for (var rowIndex = headerMatch.rowIndex + 1;
        rowIndex < rawRows.length;
        rowIndex++) {
      final row = rawRows[rowIndex];
      if (_isDescriptiveRow(row)) {
        continue;
      }

      final normalizedRow = _requiredHeaders
          .map(
            (header) => _normalizeValue(
              header,
              _readCell(row, headerMatch.columns[header]),
            ),
          )
          .toList();

      if (normalizedRow.any((value) => value.isNotEmpty)) {
        normalizedRows.add(normalizedRow);
      }
    }

    if (normalizedRows.length == 1) {
      throw GrnImportException(
        'The import file does not contain any GRN rows after the header.',
      );
    }

    return normalizedRows
        .map((row) => row.map(_escapeCsv).join(','))
        .join('\n');
  }

  void _validateCsvHeaders(String csvContent) {
    final lines = const LineSplitter().convert(csvContent);
    if (lines.isEmpty) {
      throw GrnImportException(
        'The import file is empty. Required columns: ${_requiredHeaders.join(', ')}.',
      );
    }

    final headerLine = lines.first.trim();
    if (headerLine.isEmpty) {
      throw GrnImportException(
        'The import file is empty. Required columns: ${_requiredHeaders.join(', ')}.',
      );
    }

    final headers = headerLine
        .split(',')
        .map((item) => item.trim().replaceAll('"', ''))
        .toSet();

    final missingHeaders = _requiredHeaders
        .where((header) => !headers.contains(header))
        .toList();

    if (missingHeaders.isNotEmpty) {
      throw GrnImportException(
        'Missing required columns: ${missingHeaders.join(', ')}. '
        'Expected columns: ${_requiredHeaders.join(', ')}.',
      );
    }
  }

  _HeaderRowMatch _findHeaderRow(List<List<String>> rows) {
    _HeaderRowMatch? bestMatch;
    var bestScore = -1;

    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      final mappedColumns = <String, int>{};
      var exactMatchCount = 0;

      for (var column = 0; column < row.length; column++) {
        final rawHeader = row[column];
        final normalizedHeader = _normalizeHeader(rawHeader);
        final mappedHeader = _headerAliases[normalizedHeader];
        if (mappedHeader == null || mappedColumns.containsKey(mappedHeader)) {
          continue;
        }
        mappedColumns[mappedHeader] = column;
        if (_normalizeHeader(mappedHeader) == normalizedHeader) {
          exactMatchCount++;
        }
      }

      final hasRequiredHeaders = _requiredHeaders.every(
        mappedColumns.containsKey,
      );
      if (!hasRequiredHeaders) {
        continue;
      }

      final score = (exactMatchCount * 100) + mappedColumns.length;
      if (score > bestScore) {
        bestScore = score;
        bestMatch = _HeaderRowMatch(
          rowIndex: index,
          columns: mappedColumns,
        );
      }
    }

    if (bestMatch == null) {
      throw GrnImportException(
        'Missing required columns: ${_requiredHeaders.join(', ')}.',
      );
    }

    return bestMatch;
  }

  bool _isDescriptiveRow(List<String> row) {
    final firstValue = row.firstWhere(
      (cell) => cell.isNotEmpty,
      orElse: () => '',
    );
    final firstToken = _normalizeHeader(firstValue);
    if (firstToken == 'reqfromsap' || firstToken == 'filedbyapp') {
      return true;
    }

    var mappedCount = 0;
    for (final cell in row) {
      if (_headerAliases.containsKey(_normalizeHeader(cell))) {
        mappedCount++;
      }
    }

    return mappedCount >= _requiredHeaders.length - 1;
  }

  String _readCell(List<String> row, int? index) {
    if (index == null || index < 0 || index >= row.length) {
      return '';
    }
    return row[index];
  }

  List<String> _trimTrailingEmptyColumns(List<String> row) {
    final trimmed = List<String>.from(row);
    while (trimmed.isNotEmpty && trimmed.last.isEmpty) {
      trimmed.removeLast();
    }
    return trimmed;
  }

  List<String> _parseCsvLine(String line) {
    final values = <String>[];
    final buffer = StringBuffer();
    var insideQuotes = false;

    for (var index = 0; index < line.length; index++) {
      final char = line[index];
      if (char == '"') {
        final nextIsQuote =
            index + 1 < line.length && line[index + 1] == '"';
        if (insideQuotes && nextIsQuote) {
          buffer.write('"');
          index++;
        } else {
          insideQuotes = !insideQuotes;
        }
        continue;
      }

      if (char == ',' && !insideQuotes) {
        values.add(buffer.toString().trim());
        buffer.clear();
        continue;
      }

      buffer.write(char);
    }

    values.add(buffer.toString().trim());
    return values;
  }

  String _normalizeHeader(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _normalizeValue(String header, String value) {
    var normalized = value.trim();
    if (normalized.isEmpty) {
      return normalized;
    }

    final numericWithTrailingZero = RegExp(r'^\d+\.0+$');
    if (numericWithTrailingZero.hasMatch(normalized)) {
      normalized = normalized.split('.').first;
    }

    if (header == 'postingDate') {
      final excelSerial = int.tryParse(normalized);
      if (excelSerial != null && excelSerial > 20000 && excelSerial < 80000) {
        final parsed = DateTime.utc(1899, 12, 30).add(
          Duration(days: excelSerial),
        );
        return _formatDate(parsed);
      }

      final parsedDate = DateTime.tryParse(normalized);
      if (parsedDate != null) {
        return _formatDate(parsedDate);
      }
    }

    return normalized;
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

class _HeaderRowMatch {
  const _HeaderRowMatch({
    required this.rowIndex,
    required this.columns,
  });

  final int rowIndex;
  final Map<String, int> columns;
}

class GrnImportException implements Exception {
  GrnImportException(this.message);
  final String message;

  @override
  String toString() => message;
}

final grnImportServiceProvider = Provider<GrnImportService>((ref) {
  final repo = ref.read(sapGrnRepositoryProvider);
  return GrnImportService(repo);
});
