import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../auth_repository.dart';
import '../models/user.dart';
import '../../data/auth_repository_impl.dart';

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.read(authRepositoryProvider));
});

final currentUserProvider = FutureProvider<User>((ref) async {
  final response = await ref.read(getCurrentUserUseCaseProvider).execute();
  if (response.success && response.data != null) {
    return response.data!;
  }
  final message = response.error?.message.isNotEmpty == true
      ? response.error!.message
      : response.message;
  throw Exception(message.isNotEmpty ? message : 'Failed to load user');
});

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<ApiResponse<User>> execute() {
    return _repository.getCurrentUser();
  }
}
