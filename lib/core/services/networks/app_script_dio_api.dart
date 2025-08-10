import 'package:dio/dio.dart';

import '../../../features/authentication/domain/models/google_scopes.dart';
import '../../../features/authentication/domain/repositories/google_auth_repository.dart';
import '../dio/api_result.dart';
import '../dio/google_auth_interceptor.dart';
import '../dio/interceptors.dart';

class AppScriptApiClientDio {
  AppScriptApiClientDio({
    required GoogleAuthRepository authRepo,
    required this.baseExecUrl,      // e.g. https://script.google.com/macros/s/DEPLOYMENT_ID/exec
    Dio? dio,                       // ส่งมาก็ได้ หรือให้คลาสนี้สร้างให้
  })  : _authRepo = authRepo,
        _dio = dio ?? Dio(
          BaseOptions(
            // baseUrl ไม่จำเป็น เพราะเราจะเรียกด้วย "full URL" อยู่แล้ว
            connectTimeout: const Duration(milliseconds: 15000),
            sendTimeout: const Duration(milliseconds: 15000),
            receiveTimeout: const Duration(milliseconds: 15000),
            headers: { Headers.acceptHeader: 'application/json' },
            validateStatus: (s) => s != null && s >= 200 && s < 300,
            receiveDataWhenStatusError: false,
          ),
        ) {
    // ใส่ interceptors: Auth -> Logging -> Error
    _dio.interceptors.addAll([
      GoogleAuthInterceptor(_authRepo, dio: _dio, scopes: GoogleScopes.appsScript),
      LoggingInterceptor(),
      ErrorInterceptor(),
    ]);
  }

  final GoogleAuthRepository _authRepo;
  final Dio _dio;
  final Uri baseExecUrl;

  /// GET (คืนเป็น ApiResult<Map<String, dynamic>>)
  Future<ApiResult<Map<String, dynamic>>> get({Map<String, String>? query}) async {
    try {
      final url = baseExecUrl.replace(queryParameters: query);
      final res = await _dio.get(url.toString()); // full URL => ไม่พึ่ง baseUrl
      return ApiResult.fromDioResponse<Map<String, dynamic>>(
        res, (json) => (json as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      return ApiResult.fromDioException<Map<String, dynamic>>(e);
    }
  }

  /// POST JSON (ส่ง Map ตรงๆ ให้ Dio จัด content-type เอง)
  Future<ApiResult<Map<String, dynamic>>> postJson(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(baseExecUrl.toString(), data: body);
      return ApiResult.fromDioResponse<Map<String, dynamic>>(
        res,  (json) => (json as Map).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      return ApiResult.fromDioException<Map<String, dynamic>>(e);
    }
  }

  /// ใช้เมื่อ endpoint ตอบ 204/ไม่มีบอดี้ (เช่น DELETE หรือ action-only)
  Future<ApiResult<Unit>> postEmpty(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post(baseExecUrl.toString(), data: body);
      return ApiResult.fromDioEmpty(res);
    } on DioException catch (e) {
      return ApiResult.fromDioException<Unit>(e);
    }
  }

  Future<void> close() async => _dio.close(force: true);
}
