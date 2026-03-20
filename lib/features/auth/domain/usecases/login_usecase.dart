import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_response.dart';
import '../auth_repository.dart';
import '../models/auth_result.dart';
import '../../data/dto/login_request.dart';
import '../../data/auth_repository_impl.dart';

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<ApiResponse<AuthResult>> execute(LoginRequest request) {
    return _repository.login(request);
  }
}
