import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_repository.dart';
import '../../data/auth_repository_impl.dart';
import '../../../../core/network/api_response.dart';

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.read(authRepositoryProvider));
});

class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<ApiResponse<void>> execute(
      {required String currentPassword, required String newPassword}) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
