import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/gate_entry.dart';
import '../../domain/models/gate_entry_summary.dart';
import '../../domain/models/gate_entry_query.dart';
import '../../domain/usecases/get_gate_entries_usecase.dart';
import '../../domain/usecases/create_gate_entry_usecase.dart';
import '../../domain/usecases/gate_entry_actions_usecase.dart';
import '../../domain/usecases/gate_out_usecase.dart';
import '../../data/dto/create_gate_entry_request.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/pagination_model.dart';

const _queryNotProvided = Object();

class GateEntryState {
  final bool isLoading;
  final String? error;
  final List<GateEntry> entries;
  final GateEntrySummary summary;
  final PaginationModel? pagination;
  final GateEntryQuery? activeQuery;

  GateEntryState({
    this.isLoading = false,
    this.error,
    this.entries = const [],
    this.summary = const GateEntrySummary(),
    this.pagination,
    this.activeQuery,
  });

  GateEntryState copyWith({
    bool? isLoading,
    String? error,
    List<GateEntry>? entries,
    GateEntrySummary? summary,
    Object? pagination = _queryNotProvided,
    Object? activeQuery = _queryNotProvided,
  }) {
    return GateEntryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      entries: entries ?? this.entries,
      summary: summary ?? this.summary,
      pagination: identical(pagination, _queryNotProvided)
          ? this.pagination
          : pagination as PaginationModel?,
      activeQuery: identical(activeQuery, _queryNotProvided)
          ? this.activeQuery
          : activeQuery as GateEntryQuery?,
    );
  }
}

final gateEntryControllerProvider =
    StateNotifierProvider<GateEntryController, GateEntryState>((ref) {
  return GateEntryController(
    ref: ref,
    getGateEntriesUseCase: ref.read(getGateEntriesUseCaseProvider),
    createGateEntryUseCase: ref.read(createGateEntryUseCaseProvider),
    verifyGateEntryUseCase: ref.read(verifyGateEntryUseCaseProvider),
    approveGateEntryUseCase: ref.read(approveGateEntryUseCaseProvider),
    closeGateEntryUseCase: ref.read(closeGateEntryUseCaseProvider),
    gateOutUseCase: ref.read(gateOutUseCaseProvider),
  );
});

class GateEntryController extends StateNotifier<GateEntryState> {
  final GetGateEntriesUseCase _getGateEntriesUseCase;
  final CreateGateEntryUseCase _createGateEntryUseCase;
  final VerifyGateEntryUseCase _verifyGateEntryUseCase;
  final ApproveGateEntryUseCase _approveGateEntryUseCase;
  final CloseGateEntryUseCase _closeGateEntryUseCase;
  final GateOutUseCase _gateOutUseCase;

  GateEntryController({
    required Ref ref,
    required GetGateEntriesUseCase getGateEntriesUseCase,
    required CreateGateEntryUseCase createGateEntryUseCase,
    required VerifyGateEntryUseCase verifyGateEntryUseCase,
    required ApproveGateEntryUseCase approveGateEntryUseCase,
    required CloseGateEntryUseCase closeGateEntryUseCase,
    required GateOutUseCase gateOutUseCase,
  })  : _getGateEntriesUseCase = getGateEntriesUseCase,
        _createGateEntryUseCase = createGateEntryUseCase,
        _verifyGateEntryUseCase = verifyGateEntryUseCase,
        _approveGateEntryUseCase = approveGateEntryUseCase,
        _closeGateEntryUseCase = closeGateEntryUseCase,
        _gateOutUseCase = gateOutUseCase,
        super(GateEntryState());

  Future<void> fetchEntries(
      {Object? query = _queryNotProvided,
      int? page,
      int? limit,
      bool? usePagination,
      bool refresh = false}) async {
    final baseQuery = identical(query, _queryNotProvided)
        ? state.activeQuery
        : query as GateEntryQuery?;
    final shouldPaginate = usePagination ??
        page != null ||
        limit != null ||
        state.pagination != null ||
        baseQuery?.page != null ||
        baseQuery?.limit != null;
    final effectiveQuery = shouldPaginate
        ? (baseQuery ?? const GateEntryQuery()).copyWith(
            page: refresh ? 1 : (page ?? baseQuery?.page ?? state.pagination?.page ?? 1),
            limit: _normalizeLimit(limit ?? baseQuery?.limit ?? state.pagination?.limit ?? 20),
          )
        : (baseQuery ?? const GateEntryQuery()).copyWith(
            page: null,
            limit: null,
          );

    state = state.copyWith(isLoading: true, error: null);

    final response = await _getGateEntriesUseCase.execute(query: effectiveQuery);

    if (response.success && response.data != null) {
      state = state.copyWith(
        isLoading: false,
        entries: response.data!.items,
        summary: response.data!.summary,
        pagination: response.data!.pagination,
        activeQuery: effectiveQuery,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.message,
      );
    }
  }

  void showAllEntries() {
    fetchEntries(query: null, usePagination: false);
  }

  Future<GateEntry?> createEntry(CreateGateEntryRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _createGateEntryUseCase.execute(request);

    if (response.success && response.data != null) {
      _scheduleBackgroundRefresh();
      return response.data!;
    } else {
      state = state.copyWith(isLoading: false, error: response.message);
      return null;
    }
  }

  Future<bool> verifyEntry(String id) async {
    return _handleActionVoid(
        _verifyGateEntryUseCase.execute(id), id);
  }

  Future<bool> approveEntry(String id) async {
    return _handleActionVoid(
        _approveGateEntryUseCase.execute(id), id);
  }

  Future<bool> closeEntry(String id) async {
    return _handleActionVoid(_closeGateEntryUseCase.execute(id), id);
  }

  Future<bool> gateOutEntry(String id, {String? remarks}) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _gateOutUseCase.execute(id, remarks: remarks);

    if (response.success) {
      _scheduleBackgroundRefresh();
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.message);
      return false;
    }
  }

  Future<bool> _handleActionVoid(
      Future<ApiResponse<void>> action, String id) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await action;

    if (response.success) {
      _scheduleBackgroundRefresh();
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.message);
      return false;
    }
  }

  void _scheduleBackgroundRefresh() {
    state = state.copyWith(isLoading: false, error: null);
    Future.microtask(() async {
      try {
        await fetchEntries(refresh: true);
      } catch (_) {
        // background refresh is best-effort
      }
    });
  }

  int _normalizeLimit(int value) {
    if (value < 1) return 20;
    if (value > 100) return 100;
    return value;
  }
}
