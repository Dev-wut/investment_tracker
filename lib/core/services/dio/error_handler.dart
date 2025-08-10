import 'dart:io';
import 'package:dio/dio.dart';

// เดิมของคุณ
enum DataSource {
  success,
  noContent,
  badRequest,
  forbidden,
  unauthorized,
  notFound,
  internalServerError,
  connectTimeout,
  cancel,
  receiveTimeout,
  sendTimeout,
  cacheError,
  noInternetConnection,
  unknown
}

class ErrorDetails {
  ErrorDetails(this.source, this.message, this.code);
  final DataSource source;
  final String message;
  final int code;
}

class ErrorHandler {
  static ErrorDetails handle(DioException error) {
    // 1) ดึงข้อความจากเซิร์ฟเวอร์ก่อน
    String serverMsg = _extractServerMessage(error.response?.data);

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ErrorDetails(
          DataSource.connectTimeout,
          'การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง',
          408, // ให้สื่อว่า timeout (จะใช้ -1 ก็ได้ถ้าคุณต้องการ)
        );

      case DioExceptionType.sendTimeout:
        return ErrorDetails(
          DataSource.sendTimeout,
          'การส่งข้อมูลหมดเวลา กรุณาลองใหม่อีกครั้ง',
          408,
        );

      case DioExceptionType.receiveTimeout:
        return ErrorDetails(
          DataSource.receiveTimeout,
          'การรับข้อมูลหมดเวลา กรุณาลองใหม่อีกครั้ง',
          408,
        );

      case DioExceptionType.cancel:
        return ErrorDetails(
          DataSource.cancel,
          'คำขอถูกยกเลิก',
          499, // ตามธรรมเนียม client cancel
        );

      case DioExceptionType.connectionError:
      // แยกกรณีไม่มีเน็ต/ปัญหา TLS
        final underlying = error.error;
        if (underlying is SocketException) {
          return ErrorDetails(
            DataSource.noInternetConnection,
            'ไม่พบการเชื่อมต่ออินเทอร์เน็ต กรุณาตรวจสอบเครือข่าย',
            -1,
          );
        }
        // Handshake / TLS อาจเจอเป็น HandshakeException
        if (underlying is HandshakeException) {
          return ErrorDetails(
            DataSource.unknown,
            'เชื่อมต่อไม่ได้ (ปัญหาใบรับรอง/การเข้ารหัส) กรุณาลองใหม่หรือตรวจสอบเวลาในเครื่อง',
            -1,
          );
        }
        return ErrorDetails(
          DataSource.unknown,
          'เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่',
          -1,
        );

      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? -1;

        // ข้อความ: ให้ใช้ของเซิร์ฟเวอร์ถ้ามี ไม่งั้นข้อความดีฟอลต์ตามสถานะ
        String message = serverMsg.isNotEmpty ? serverMsg : _messageForStatus(status);

        // จัด DataSource ตามกลุ่มสถานะ
        final DataSource source = switch (status) {
          204 => DataSource.noContent,
          400 || 422 => DataSource.badRequest,   // 422: validation
          401 => DataSource.unauthorized,
          403 => DataSource.forbidden,
          404 => DataSource.notFound,
          429 => DataSource.forbidden,          // หรือสร้าง enum ใหม่ tooManyRequests
          >= 500 && <= 599 => DataSource.internalServerError,
          _ => DataSource.unknown,
        };

        return ErrorDetails(
          source,
          message,
          status,
        );

      case DioExceptionType.unknown:
      default:
      // อาจเป็น exception อื่นๆ ที่ไม่เข้ากลุ่มด้านบน
        final msg = serverMsg.isNotEmpty ? serverMsg : 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';
        final status = error.response?.statusCode ?? -1;
        return ErrorDetails(DataSource.unknown, msg, status);
    }
  }

  // ดึงข้อความจากโครงสร้างยอดฮิตของ backend
  static String _extractServerMessage(dynamic data) {
    if (data == null) return '';
    if (data is String) return data.trim();

    if (data is Map) {
      // ลอง key ชื่อที่พบบ่อย
      final keys = [
        'message', 'msg', 'error', 'detail', 'title', 'description',
        'error_message', 'error_description',
      ];
      for (final k in keys) {
        final v = data[k];
        if (v is String && v.trim().isNotEmpty) return v.trim();
        if (v is Map || v is List) {
          final inner = _extractServerMessage(v);
          if (inner.isNotEmpty) return inner;
        }
      }

      // รูปแบบ errors: [{message: ...}] หรือ errors: ["..."]
      final errors = data['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is String && first.trim().isNotEmpty) return first.trim();
        if (first is Map) {
          final cand = _extractServerMessage(first);
          if (cand.isNotEmpty) return cand;
        }
      }
    }

    if (data is List && data.isNotEmpty) {
      // กรณี backend ส่งเป็น list ของข้อความ
      final first = data.first;
      if (first is String && first.trim().isNotEmpty) return first.trim();
      if (first is Map) {
        final cand = _extractServerMessage(first);
        if (cand.isNotEmpty) return cand;
      }
    }

    return '';
  }

  static String _messageForStatus(int status) {
    return switch (status) {
      204 => 'ไม่มีข้อมูล',
      400 => 'คำขอไม่ถูกต้อง กรุณาตรวจสอบข้อมูล',
      401 => 'ไม่มีสิทธิ์เข้าถึง กรุณาเข้าสู่ระบบใหม่',
      403 => 'ไม่มีสิทธิ์เข้าถึงข้อมูลนี้',
      404 => 'ไม่พบข้อมูลที่ต้องการ',
      408 => 'หมดเวลาในการเชื่อมต่อ กรุณาลองใหม่',
      413 => 'ไฟล์/ข้อมูลใหญ่เกินไป',
      415 => 'ชนิดข้อมูลไม่รองรับ',
      422 => 'ข้อมูลไม่ผ่านการตรวจสอบความถูกต้อง',
      429 => 'ส่งคำขอบ่อยเกินไป กรุณาลองใหม่ภายหลัง',
      500 => 'เกิดข้อผิดพลาดที่เซิร์ฟเวอร์',
      502 => 'เกตเวย์ผิดพลาด',
      503 => 'บริการไม่พร้อมใช้งาน',
      504 => 'เกตเวย์หมดเวลา',
      _   => 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ',
    };
  }
}
