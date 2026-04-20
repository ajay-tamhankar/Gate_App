import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/gate_entry.dart';
import '../../domain/models/gate_entry_query.dart';
import '../../domain/usecases/get_gate_entries_usecase.dart';
import '../../domain/usecases/create_gate_entry_usecase.dart';
import '../../domain/usecases/gate_entry_actions_usecase.dart';
import '../../domain/usecases/gate_out_usecase.dart';
import '../../data/dto/create_gate_entry_request.dart';
import '../../../../core/network/api_response.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';

const _queryNotProvided = Object();

class GateEntryState {
  final bool isLoading;
  final String? error;
  final List<GateEntry> entries;
  final List<GateEntry> allEntries;
  final GateEntryQuery? activeQuery;

  GateEntryState({
    this.isLoading = false,
    this.error,
    this.entries = const [],
    this.allEntries = const [],
    this.activeQuery,
  });

  GateEntryState copyWith({
    bool? isLoading,
    String? error,
    List<GateEntry>? entries,
    List<GateEntry>? allEntries,
    Object? activeQuery = _queryNotProvided,
  }) {
    return GateEntryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      entries: entries ?? this.entries,
      allEntries: allEntries ?? this.allEntries,
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
  final Ref _ref;
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
  })  : _ref = ref,
        _getGateEntriesUseCase = getGateEntriesUseCase,
        _createGateEntryUseCase = createGateEntryUseCase,
        _verifyGateEntryUseCase = verifyGateEntryUseCase,
        _approveGateEntryUseCase = approveGateEntryUseCase,
        _closeGateEntryUseCase = closeGateEntryUseCase,
        _gateOutUseCase = gateOutUseCase,
        super(GateEntryState());

  Future<void> fetchEntries(
      {Object? query = _queryNotProvided,
      bool refresh = false,
      bool syncAllEntries = false}) async {
    if (state.isLoading) return;

    final effectiveQuery = identical(query, _queryNotProvided)
        ? state.activeQuery
        : query as GateEntryQuery?;
    final shouldSyncAllEntries =
        refresh || syncAllEntries || state.allEntries.isEmpty;

    state = state.copyWith(isLoading: true, error: null);

    List<GateEntry>? refreshedAllEntries;
    if (shouldSyncAllEntries) {
      final allResponse = await _getGateEntriesUseCase.execute();
      if (allResponse.success && allResponse.data != null) {
        refreshedAllEntries = allResponse.data!.items;
      } else if (effectiveQuery == null) {
        state = state.copyWith(
          isLoading: false,
          error: allResponse.message,
        );
        return;
      }
    }

    if (effectiveQuery == null && refreshedAllEntries != null) {
      state = state.copyWith(
        isLoading: false,
        entries: refreshedAllEntries,
        allEntries: refreshedAllEntries,
        activeQuery: null,
      );
      return;
    }

    final response = await _getGateEntriesUseCase.execute(query: effectiveQuery);

    if (response.success && response.data != null) {
      final nextEntries = response.data!.items;
      final nextAllEntries = refreshedAllEntries ??
          (effectiveQuery == null ? nextEntries : state.allEntries);

      state = state.copyWith(
        isLoading: false,
        entries: nextEntries,
        allEntries: nextAllEntries,
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
    state = state.copyWith(
      entries: state.allEntries.isNotEmpty ? state.allEntries : state.entries,
      activeQuery: null,
      error: null,
    );
  }

  Future<GateEntry?> createEntry(CreateGateEntryRequest request) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await _createGateEntryUseCase.execute(request);

    if (response.success && response.data != null) {
      // Prepend to current list
      state = state.copyWith(
        isLoading: false,
        entries: [response.data!, ...state.entries],
      );
      _ref.invalidate(dashboardControllerProvider);
      return response.data!;
    } else {
      state = state.copyWith(isLoading: false, error: response.message);
      return null;
    }
  }

  Future<bool> verifyEntry(String id) async {
    return _handleActionVoid(
        _verifyGateEntryUseCase.execute(id), id, 'verification_pending');
  }

  Future<bool> approveEntry(String id) async {
    return _handleActionVoid(
        _approveGateEntryUseCase.execute(id), id, 'approved');
  }

  Future<bool> closeEntry(String id) async {
    return _handleActionVoid(_closeGateEntryUseCase.execute(id), id, 'closed');
  }

  Future<bool> gateOutEntry(String id, {String? remarks}) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _gateOutUseCase.execute(id, remarks: remarks);

    if (response.success) {
      await fetchEntries(refresh: true);
      _ref.invalidate(dashboardControllerProvider);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.message);
      return false;
    }
  }

  Future<bool> _handleActionVoid(
      Future<ApiResponse<void>> action, String id, String newMockStatus) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await action;

    if (response.success) {
      // Optimistically update entry status locally if needed, doing a reload is safer.
      // Re-fetch or manually mutate the item object in the list
      await fetchEntries(refresh: true);
      _ref.invalidate(dashboardControllerProvider);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.message);
      return false;
    }
  }
}
