import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_cleanup.dart';
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
            user: response.data!,
            organization: response.data!.organization!,
            role: parsedRole,
          );
        } else {
          await _clearSession();
        }
      } catch (e) {
        await _clearSession();
      }
    } else {
      state = const Unauthenticated();
    }
  }

  Future<String?> login({
    required String organizationCode,
    required String identifier,
    required String password,
  }) async {
    state = const SessionLoading();
    final loginUseCase = ref.read(loginUseCaseProvider);

    final response = await loginUseCase.execute(
      LoginRequest.fromIdentifier(
        organizationCode: organizationCode,
        identifier: identifier,
        password: password,
      ),
    );

    if (response.success && response.data != null) {
      final parsedRole = UserRole.fromApi(response.data!.role) ??
          UserRole.admin; // Fallback

      state = Authenticated(
        user: response.data!.user,
        organization: response.data!.organization,
        role: parsedRole,
      );
      return null;
    } else {
      state = const Unauthenticated();
      final message = [
        response.error?.message,
        response.message,
      ].whereType<String>().map((e) => e.trim()).firstWhere(
            (e) => e.isNotEmpty,
            orElse: () => '',
          );

      if (_looksLikeNetworkIssue(message)) {
        return 'Unable to sign in right now. Please try again.';
      }

      return 'Invalid organization code, email, or password.';
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    clearOrgScopedState(ref);
    state = const Unauthenticated();
  }

  bool get isAuthed => state is Authenticated;

  Authenticated? get authedOrNull =>
      state is Authenticated ? state as Authenticated : null;

  Future<void> invalidateSession() async {
    await _clearSession();
  }

  Future<void> _clearSession() async {
    await ref.read(tokenStorageProvider).deleteToken();
    clearOrgScopedState(ref);
    state = const Unauthenticated();
  }

  bool _looksLikeNetworkIssue(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('network') ||
        normalized.contains('socket') ||
        normalized.contains('timeout') ||
        normalized.contains('connection');
  }
}
