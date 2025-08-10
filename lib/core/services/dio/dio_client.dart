import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import 'interceptors.dart';

class DioClient {
  // singleton
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: 15000),
        sendTimeout: const Duration(milliseconds: 15000),
        receiveTimeout: const Duration(milliseconds: 15000),
        // ไม่จำเป็นต้องตั้ง responseType/contentType ถ้าไม่มีเคสพิเศษ
        // responseType: ResponseType.json, // (ค่า default คือ json)
        // contentType: Headers.jsonContentType, // ถ้าจำเป็นค่อยเปิด
        headers: <String, String>{
          Headers.acceptHeader: 'application/json',
        },
        // ให้ถือว่าสำเร็จเฉพาะ 2xx (ปรับได้ตามสไตล์การจัดการ error)
        validateStatus: (status) => status != null && status >= 200 && status < 300,
        receiveDataWhenStatusError: false, // ไม่ต้องอ่านบอดี้เมื่อ error
      ),
    );

    _dio.interceptors.addAll([
      LoggingInterceptor(), // ตรวจให้ใช้ Interceptor ของ Dio
      ErrorInterceptor(),   // และ onError(DioException ...) แล้ว
    ]);
  }

  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio _dio;

  Dio get dio => _dio;

  // ---- Strongly-typed helpers (generic) ----
  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
