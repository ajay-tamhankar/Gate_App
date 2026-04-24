import '../../../../core/network/pagination_model.dart';
import 'gate_entry.dart';
import 'gate_entry_summary.dart';

class GateEntryListResponse {
  const GateEntryListResponse({
    required this.items,
    this.summary = const GateEntrySummary(),
    this.pagination,
  });

  final List<GateEntry> items;
  final GateEntrySummary summary;
  final PaginationModel? pagination;
}
