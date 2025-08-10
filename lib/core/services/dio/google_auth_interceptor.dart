import 'package:dio/dio.dart';
import '../../../features/authentication/domain/repositories/google_auth_repository.dart';
import '../../../features/authentication/domain/models/google_scopes.dart';

class GoogleAuthInterceptor extends Interceptor {
  GoogleAuthInterceptor(
      this._authRepo, {
        Dio? dio,
        List<String> scopes = GoogleScopes.appsScript,
      })  : _dio = dio,
        _scopes = scopes;

  final GoogleAuthRepository _authRepo;
  final Dio? _dio;
  final List<String> _scopes;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _authRepo.getAccessToken(scopes: _scopes);
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } catch (e, st) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: e,
          stackTrace: st,
          message: 'Failed to attach Google OAuth token',
        ),
      );
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra['__retried'] == true;

    final shouldRetry = _dio != null &&
        !alreadyRetried &&
        (status == 401 || status == 403);

    if (!shouldRetry) return handler.next(err);

    try {
      // รีเฟรช token แบบบังคับ (soft TTL = 0)
      final token = await _authRepo.getAccessToken(
        scopes: _scopes,
        softTtlMinutes: 0,
      );

      final req = err.requestOptions;
      req.headers['Authorization'] = 'Bearer $token';
      req.extra['__retried'] = true;
      req.extra['isRetry'] = true;

      final res = await _dio.fetch(req);
      return handler.resolve(res);
    } catch (_) {
      return handler.next(err);
    }
  }
}
