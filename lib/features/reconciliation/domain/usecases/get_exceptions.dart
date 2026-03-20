import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/reco_repository_impl.dart';
import '../entities/reco_exception.dart';

final getExceptionsProvider = FutureProvider<List<RecoException>>((ref) async {
  final repository = ref.watch(recoRepositoryProvider);
  return repository.getExceptions();
});
