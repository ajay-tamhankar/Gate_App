import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/reco_repository_impl.dart';

import '../../domain/usecases/get_exceptions.dart';
import '../../domain/entities/reco_exception.dart';
import '../../../../core/auth/session_controller.dart';
import '../../../../core/auth/session_state.dart';
import '../../../reports/data/audit_repository_impl.dart';

class RecoListController extends AsyncNotifier<List<RecoException>> {
  @override
  Future<List<RecoException>> build() async {
    return ref.watch(getExceptionsProvider.future);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(recoRepositoryProvider);
      return repository.getExceptions();
    });
  }

  Future<void> resolveException(String id, String notes) async {
    final session = ref.read(sessionControllerProvider);
    final userId = session is Authenticated ? session.userId : 'Unknown';
    final role = session is Authenticated ? session.role.label : 'Unknown';

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(recoRepositoryProvider);
      await repository.resolveException(id, notes);

      await ref.read(auditRepositoryProvider).logAction(
          userId,
          role,
          'Reconciliation',
          'Resolve',
          'User resolved Exception ID $id with notes: $notes');

      return repository.getExceptions();
    });
  }
}

final recoListControllerProvider =
    AsyncNotifierProvider<RecoListController, List<RecoException>>(
  RecoListController.new,
);
