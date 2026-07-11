import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reco_repository_impl.dart';
import '../entities/reco_exception.dart';

// autoDispose so the parsed exception list drops out of memory when nothing
// is watching it. Without this, the list stays warm for the life of the
// ProviderScope even after the user leaves the screen.
final getExceptionsProvider =
    FutureProvider.autoDispose<List<RecoException>>((ref) async {
  final repository = ref.watch(recoRepositoryProvider);
  return repository.getExceptions();
});
