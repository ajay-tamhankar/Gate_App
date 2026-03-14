import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../auth/session_controller.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ));

  final refreshLock = _RefreshLock();

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = ref
          .read(sessionControllerProvider.notifier)
          .authedOrNull
          ?.role; // Should be AccessToken in reality
      if (token != null) {
        options.headers['Authorization'] =
            'Bearer $token'; // Mock passing something initially
      }
      handler.next(options);
    },
    onError: (e, handler) async {
      final status = e.response?.statusCode;
      final isAuthError = status == 401;
      final alreadyRetried = e.requestOptions.extra['retried'] == true;

      // Note: Full refresh token logic will go here when AuthRepository is fully real
      if (!isAuthError || alreadyRetried) {
        return handler.next(e);
      }

      // Mock refresh handler structure
      try {
        await refreshLock.runOnce(() async {
          // final authRepo = ref.read(authRepositoryProvider);
          // final refreshed = await authRepo.refreshSession();
          // await ref.read(sessionControllerProvider.notifier)
          //     .updateAccessToken(refreshed.accessToken);
        });

        // Retry original request (Mock)
        final req = e.requestOptions;
        req.extra['retried'] = true;
        // req.headers['Authorization'] = 'Bearer $new_mock_token';

        final clonedResponse = await dio.fetch(req);
        return handler.resolve(clonedResponse);
      } catch (_) {
        ref.read(sessionControllerProvider.notifier).logout();
        return handler.next(e);
      }
    },
  ));

  return dio;
});

class _RefreshLock {
  Future<void>? _inFlight;
  Future<void> runOnce(Future<void> Function() action) {
    _inFlight ??= action().whenComplete(() => _inFlight = null);
    return _inFlight!;
  }
}
