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
  
  // Relaxed headers based on new API documentation support for "Details Report" style
  static const List<String> _requiredHeaders = [
    'poNumber',
    'materialCode',
    'grnNumber',
    'postingDate',
    'grnQty', // Added as per new API doc Section 9
  ];

  /// Uploads [file] to POST /sap/grns/import.
  /// Throws a [GrnImportException] on failure.
  Future<GrnImportResult?> importGrn(
    PlatformFile file, {
    bool runReconciliation = false,
  }) async {
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
        bytes = await _readFileBytes(file);
        final csvContent = utf8.decode(bytes, allowMalformed: true);
        _validateCsvHeaders(csvContent);
        filePath = kIsWeb ? null : file.path;
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
        runReconciliation: runReconciliation,
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

      final rows = sheet.rows
          .where((row) => row.any((cell) => cell?.value != null))
          .map(
            (row) => row.map((cell) => _escapeCsv(_cellToString(cell?.value))).join(','),
          )
          .toList();

      if (rows.isEmpty) {
        throw GrnImportException('The XLSX file is empty.');
      }

      return rows.join('\n');
    } catch (e) {
      if (e is GrnImportException) rethrow;
      throw GrnImportException('Failed to read XLSX file.');
    }
  }

  String _cellToString(dynamic value) {
    if (value == null) return '';
    return value.toString();
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
