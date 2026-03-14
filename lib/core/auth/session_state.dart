import 'user_role.dart';

sealed class SessionState {
  const SessionState();
}

class SessionLoading extends SessionState {
  const SessionLoading();
}

class Unauthenticated extends SessionState {
  const Unauthenticated();
}

class Authenticated extends SessionState {
  final String userId;
  final UserRole role;

  const Authenticated({required this.userId, required this.role});
}
