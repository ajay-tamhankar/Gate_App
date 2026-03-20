import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reco_exception.dart';
import '../../data/reco_repository_impl.dart';

class RecoExceptionDetailController
    extends FamilyAsyncNotifier<RecoException, String> {
  @override
  Future<RecoException> build(String id) async {
    final repository = ref.read(recoRepositoryProvider);
    return repository.getExceptionDetail(id);
  }
}

final recoExceptionDetailProvider = AsyncNotifierProviderFamily<
    RecoExceptionDetailController, RecoException, String>(
  RecoExceptionDetailController.new,
);
