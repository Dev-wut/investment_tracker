// api_result.dart
import 'package:dio/dio.dart';
import 'error_handler.dart';

/// ใช้แทนค่าที่ "ว่างแต่สำเร็จ" (เช่น 204 No Content)
class Unit {
  const Unit();
  @override
  String toString() => 'Unit';
}

const unit = Unit();

typedef Decoder<T> = T Function(dynamic json);

class ApiResult<T> {
  const ApiResult._({
    required this.success,
    this.data,
    this.errorMessage,
    this.errorCode,
    this.statusCode,
    this.source,
    this.raw,
    this.requestId,
    this.durationMs,
  });

  // ===== ผลลัพธ์หลัก =====
  final bool success;
  final T? data;
  final String? errorMessage;
  final int? errorCode;

  // ===== เมทาดาทาเสริม (เลือกใช้ได้) =====
  final int? statusCode;     // HTTP status
  final DataSource? source;  // จาก ErrorHandler.handle
  final dynamic raw;         // payload ดิบจากเซิร์ฟเวอร์ (เพื่อดีบัก)
  final String? requestId;   // จาก LoggingInterceptor (options.extra['logId'])
  final int? durationMs;     // ระยะเวลา request โดยประมาณจาก options.extra['ts']

  // ===== factories =====
  factory ApiResult.success(
      T data, {
        int? statusCode,
        dynamic raw,
        String? requestId,
        int? durationMs,
      }) {
    return ApiResult._(
      success: true,
      data: data,
      statusCode: statusCode,
      raw: raw,
      requestId: requestId,
      durationMs: durationMs,
    );
  }

  factory ApiResult.failure({
    String? errorMessage,
    int? errorCode,
    int? statusCode,
    DataSource? source,
    dynamic raw,
    String? requestId,
    int? durationMs,
  }) {
    return ApiResult._(
      success: false,
      errorMessage: errorMessage ?? 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ',
      errorCode: errorCode ?? -1,
      statusCode: statusCode,
      source: source,
      raw: raw,
      requestId: requestId,
      durationMs: durationMs,
    );
  }

  // ===== utilities =====
  ApiResult<U> map<U>(U Function(T data) transform) {
    if (success && data != null) {
      return ApiResult<U>.success(
        transform(data as T),
        statusCode: statusCode,
        raw: raw,
        requestId: requestId,
        durationMs: durationMs,
      );
    }
    return ApiResult<U>.failure(
      errorMessage: errorMessage,
      errorCode: errorCode,
      statusCode: statusCode,
      source: source,
      raw: raw,
      requestId: requestId,
      durationMs: durationMs,
    );
  }

  ApiResult<T> mapError(String Function(String? msg, int? code) transform) {
    if (success) return this;
    final newMsg = transform(errorMessage, errorCode);
    return ApiResult<T>.failure(
      errorMessage: newMsg,
      errorCode: errorCode,
      statusCode: statusCode,
      source: source,
      raw: raw,
      requestId: requestId,
      durationMs: durationMs,
    );
  }

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String? message, int? code) onFailure,
  }) {
    return success && data != null
        ? onSuccess(data as T)
        : onFailure(errorMessage, errorCode);
  }

  // ===== helpers สำหรับใช้งานกับ Dio =====

  /// ใช้เมื่อ "คาดหวังบอดี้" แล้วอยากแปลงเป็น T ด้วย [decode]
  static ApiResult<T> fromDioResponse<T>(
      Response response,
      Decoder<T> decode, {
        String Function(dynamic payload)? serverMsgPicker,
      }) {
    final reqId = response.requestOptions.extra['logId']?.toString();
    final ts = response.requestOptions.extra['ts'] as int?;
    final dur =
    ts != null ? (DateTime.now().millisecondsSinceEpoch - ts) : null;

    final status = response.statusCode ?? -1;
    final raw = response.data;

    try {
      final T parsed = decode(raw); // ให้ decoder จัดการโครงสร้างเอง
      return ApiResult<T>.success(
        parsed,
        statusCode: status,
        raw: raw,
        requestId: reqId,
        durationMs: dur,
      );
    } catch (_) {
      final msg = serverMsgPicker?.call(raw) ??
          'รูปแบบข้อมูลไม่ถูกต้อง (decode ไม่สำเร็จ)';
      return ApiResult<T>.failure(
        errorMessage: msg,
        errorCode: -1,
        statusCode: status,
        source: status >= 400 ? DataSource.badRequest : DataSource.unknown,
        raw: raw,
        requestId: reqId,
        durationMs: dur,
      );
    }
  }

  /// ใช้เมื่อ "ไม่คาดหวังบอดี้" เช่น 204/DELETE/POST ที่ตอบเปล่า
  static ApiResult<Unit> fromDioEmpty(Response response) {
    final reqId = response.requestOptions.extra['logId']?.toString();
    final ts = response.requestOptions.extra['ts'] as int?;
    final dur =
    ts != null ? (DateTime.now().millisecondsSinceEpoch - ts) : null;

    final status = response.statusCode ?? 204;

    if (status >= 200 && status < 300) {
      return ApiResult<Unit>.success(
        unit,
        statusCode: status,
        raw: response.data,
        requestId: reqId,
        durationMs: dur,
      );
    } else {
      return ApiResult<Unit>.failure(
        errorMessage: 'คำขอไม่สำเร็จ',
        errorCode: status,
        statusCode: status,
        source: status >= 500
            ? DataSource.internalServerError
            : DataSource.badRequest,
        raw: response.data,
        requestId: reqId,
        durationMs: dur,
      );
    }
  }

  /// ใช้ใน `catch (DioException e)` เพื่อแปลง Error -> ApiResult
  static ApiResult<T> fromDioException<T>(DioException err) {
    final ed = ErrorHandler.handle(err);
    final status = err.response?.statusCode ?? (ed.code > 0 ? ed.code : null);

    final reqId = err.requestOptions.extra['logId']?.toString();
    final ts = err.requestOptions.extra['ts'] as int?;
    final dur =
    ts != null ? (DateTime.now().millisecondsSinceEpoch - ts) : null;

    return ApiResult<T>.failure(
      errorMessage: ed.message,
      errorCode: ed.code,
      statusCode: status,
      source: ed.source,
      raw: err.response?.data,
      requestId: reqId,
      durationMs: dur,
    );
  }
}
