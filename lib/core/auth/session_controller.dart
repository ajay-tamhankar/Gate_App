import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_state.dart';
import 'user_role.dart';
import '../network/token_storage.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/data/dto/login_request.dart';
import '../../features/auth/data/auth_repository_impl.dart';

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    // Attempt to restore session on initialization
    _restoreSession();
    return const SessionLoading();
  }

  Future<void> _restoreSession() async {
    final token = await ref.read(tokenStorageProvider).getToken();
    if (token != null) {
      try {
        final getCurrentUser = ref.read(getCurrentUserUseCaseProvider);
        final response = await getCurrentUser.execute();
        
        if (response.success && response.data != null) {
          final parsedRole = UserRole.fromApi(response.data!.role) ?? UserRole.admin;
          state = Authenticated(
            userId: response.data!.id,
            role: parsedRole,
          );
        } else {
          await ref.read(tokenStorageProvider).deleteToken();
          state = const Unauthenticated();
        }
      } catch (e) {
        // If API fails (e.g., offline), we either keep them Unauthenticated 
        // or Authenticated based on cached. For now, clear session to be safe.
        await ref.read(tokenStorageProvider).deleteToken();
        state = const Unauthenticated();
      }
    } else {
      state = const Unauthenticated();
    }
  }

  Future<String?> login({required String username, required String password}) async {
    state = const SessionLoading();
    final loginUseCase = ref.read(loginUseCaseProvider);

    final response = await loginUseCase
        .execute(LoginRequest(username: username, password: password));

    if (response.success && response.data != null) {
      final parsedRole = UserRole.fromApi(response.data!.role) ??
          UserRole.admin; // Fallback

      state = Authenticated(
        userId: response.data!.userId,
        role: parsedRole,
      );
      return null;
    } else {
      state = const Unauthenticated();
      return response.error?.message.isNotEmpty == true
          ? response.error!.message
          : (response.message.isNotEmpty
              ? response.message
              : 'Login failed. Please check your credentials.');
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const Unauthenticated();
  }

  bool get isAuthed => state is Authenticated;

  Authenticated? get authedOrNull =>
      state is Authenticated ? state as Authenticated : null;
}
