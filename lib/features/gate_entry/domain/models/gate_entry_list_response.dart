import '../../../../core/network/pagination_model.dart';
import 'gate_entry.dart';

class GateEntryListResponse {
  const GateEntryListResponse({
    required this.items,
    this.pagination,
  });

  final List<GateEntry> items;
  final PaginationModel? pagination;
}
