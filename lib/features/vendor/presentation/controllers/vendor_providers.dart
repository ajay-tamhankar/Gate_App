import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/vendor_repository_impl.dart';
import '../../domain/models/vendor.dart';
import '../../domain/vendor_repository.dart';

final vendorListQueryProvider = StateProvider<VendorListQuery>((ref) {
  return const VendorListQuery();
});

final vendorListProvider =
    FutureProvider.autoDispose<VendorListResult>((ref) async {
  final query = ref.watch(vendorListQueryProvider);
  final repo = ref.read(vendorRepositoryProvider);
  return repo.listVendors(query);
});

class VendorActionController extends StateNotifier<AsyncValue<void>> {
  VendorActionController(this._repo) : super(const AsyncData(null));

  final VendorRepository _repo;

  /// Result of the last failed action — captured on the controller (instead of
  /// only in `state`) so callers can still see the error reason even if the
  /// notifier got disposed during the await. Cleared at the start of each call.
  Object? lastError;

  void _setState(AsyncValue<void> next) {
    // Guard every state mutation: if the notifier was disposed during the
    // await, silently no-op rather than throwing "Bad state: Tried to use
    // VendorActionController after dispose was called". The dialog still gets
    // the return value and the captured `lastError`, so the UI flow works.
    if (mounted) state = next;
  }

  Future<Vendor?> create(VendorWriteRequest request) async {
    lastError = null;
    _setState(const AsyncLoading());
    try {
      final vendor = await _repo.createVendor(request);
      _setState(const AsyncData(null));
      return vendor;
    } catch (e, st) {
      lastError = e;
      _setState(AsyncError(e, st));
      return null;
    }
  }

  Future<Vendor?> update(String id, VendorWriteRequest request) async {
    lastError = null;
    _setState(const AsyncLoading());
    try {
      final vendor = await _repo.updateVendor(id, request);
      _setState(const AsyncData(null));
      return vendor;
    } catch (e, st) {
      lastError = e;
      _setState(AsyncError(e, st));
      return null;
    }
  }

  Future<bool> delete(String id, {bool hard = false}) async {
    lastError = null;
    _setState(const AsyncLoading());
    try {
      await _repo.deleteVendor(id, hard: hard);
      _setState(const AsyncData(null));
      return true;
    } catch (e, st) {
      lastError = e;
      _setState(AsyncError(e, st));
      return false;
    }
  }
}

// NOT autoDispose on purpose: the dialog reads the notifier and awaits an
// HTTP round-trip. With autoDispose the controller can be disposed mid-await,
// and the post-await `state = AsyncData(null)` setter then throws
// "Bad state: Tried to use VendorActionController after dispose" — leaving
// the dialog open even though the API call already succeeded.
final vendorActionControllerProvider =
    StateNotifierProvider<VendorActionController, AsyncValue<void>>((ref) {
  final repo = ref.read(vendorRepositoryProvider);
  return VendorActionController(repo);
});
