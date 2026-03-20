import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImportHistoryItem {
  final DateTime timestamp;
  final String fileName;
  final bool success;
  final String message;

  ImportHistoryItem({
    required this.timestamp,
    required this.fileName,
    required this.success,
    required this.message,
  });
}

class ImportHistoryController
    extends StateNotifier<List<ImportHistoryItem>> {
  ImportHistoryController() : super(const []);

  void addItem(ImportHistoryItem item) {
    state = [item, ...state];
  }
}

final importHistoryProvider =
    StateNotifierProvider<ImportHistoryController, List<ImportHistoryItem>>(
  (ref) => ImportHistoryController(),
);
