import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_state.dart';
import 'user_role.dart';

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    // Start logged out
    return const Unauthenticated();
  }

  void loginMock({required String username, required UserRole role}) {
    state = Authenticated(
      userId: username.trim().isEmpty ? "user" : username,
      role: role,
    );
  }

  void logout() {
    state = const Unauthenticated();
  }

  bool get isAuthed => state is Authenticated;

  Authenticated? get authedOrNull =>
      state is Authenticated ? state as Authenticated : null;
}
