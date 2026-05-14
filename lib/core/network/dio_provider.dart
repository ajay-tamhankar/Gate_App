import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../auth/session_controller.dart';
import '../auth/session_state.dart';
import 'token_storage.dart';
import 'api_client.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider));
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: Env.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  if (Env.isDebug) {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: false,
      responseBody: false,
      requestHeader: false,
      responseHeader: false,
      error: true,
    ));
  }

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final session = ref.read(sessionControllerProvider);
      final sessionController = ref.read(sessionControllerProvider.notifier);
      final tokenStorage = ref.read(tokenStorageProvider);
      final token =
          tokenStorage.cachedToken ?? await tokenStorage.getToken();
      final isAuthRequest = options.path.startsWith('/auth/');

      if (!isAuthRequest &&
          (sessionController.isClearingSession ||
              session is Unauthenticated ||
              token == null ||
              token.isEmpty)) {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: 'Request cancelled because the session is inactive.',
          ),
        );
      }

      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (e, handler) async {
      final status = e.response?.statusCode;
      final isAuthError = status == 401;

      if (isAuthError) {
        await ref.read(sessionControllerProvider.notifier).invalidateSession();
      }

      return handler.next(e);
    },
  ));

  return dio;
});
