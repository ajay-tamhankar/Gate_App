import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_reco_repository.dart';
import '../entities/reco_exception.dart';
import '../reco_repository.dart';

final recoRepositoryProvider = Provider<RecoRepository>((ref) {
  return MockRecoRepository();
});

final getExceptionsProvider = FutureProvider<List<RecoException>>((ref) async {
  final repository = ref.watch(recoRepositoryProvider);
  return repository.getExceptions();
});
