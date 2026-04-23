import 'user_role.dart';
import '../../features/auth/domain/models/organization.dart';
import '../../features/auth/domain/models/user.dart';

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
  final User user;
  final Organization organization;
  final UserRole role;

  const Authenticated({
    required this.user,
    required this.organization,
    required this.role,
  });

  String get userId => user.id;
  String get fullName => user.fullName;
}
