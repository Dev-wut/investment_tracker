import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';

import 'error_handler.dart';

class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    this.enabled = true,
    this.maxBodyChars = 2000,
  });

  final bool enabled;
  final int maxBodyChars;

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final redacted = Map<String, dynamic>.from(headers);
    for (final k in headers.keys) {
      final key = k.toString().toLowerCase();
      if (key == 'authorization' || key == 'cookie' || key == 'set-cookie' || key == 'x-api-key') {
        redacted[k] = '***';
      }
    }
    return redacted;
  }

  String _prettyBody(Object? data) {
    try {
      if (data == null) return 'null';
      if (data is FormData) {
        return 'FormData(fields: ${data.fields.length}, files: ${data.files.length})';
      }
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
      return data.toString();
    } catch (_) {
      return data.toString();
    }
  }

  String _shorten(String s) {
    if (s.length <= maxBodyChars) return s;
    return '${s.substring(0, maxBodyChars)}… (${s.length} chars)';
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) return handler.next(options);

    final id = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    options.extra['logId'] = id;
    options.extra['ts'] = DateTime.now().millisecondsSinceEpoch;

    log('[$id] ➡️ ${options.method} ${options.uri}');
    if (options.queryParameters.isNotEmpty) {
      log('[$id] query: ${_prettyBody(options.queryParameters)}');
    }
    log('[$id] headers: ${_redactHeaders(options.headers)}');

    if (options.data != null) {
      log('[$id] body: ${_shorten(_prettyBody(options.data))}');
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!enabled) return handler.next(response);

    final id = response.requestOptions.extra['logId'] ?? '-';
    final ts = response.requestOptions.extra['ts'] as int?;
    final ms = ts != null ? (DateTime.now().millisecondsSinceEpoch - ts) : null;

    log('[$id] ⬅️ ${response.statusCode} ${response.requestOptions.uri}${ms != null ? ' (${ms}ms)' : ''}');
    log('[$id] data: ${_shorten(_prettyBody(response.data))}');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) return handler.next(err);

    final id = err.requestOptions.extra['logId'] ?? '-';
    final ts = err.requestOptions.extra['ts'] as int?;
    final ms = ts != null ? (DateTime.now().millisecondsSinceEpoch - ts) : null;

    log('[$id] ❌ ${err.response?.statusCode ?? '-'} ${err.requestOptions.uri}${ms != null ? ' (${ms}ms)' : ''}');
    log('[$id] type: ${err.type} | message: ${err.message}');
    if (err.response?.data != null) {
      log('[$id] error body: ${_shorten(_prettyBody(err.response!.data))}');
    }

    handler.next(err);
  }
}

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final ErrorDetails ed = ErrorHandler.handle(err);

    final Response<Map<String, dynamic>> shaped = (err.response != null)
        ? Response<Map<String, dynamic>>(
            requestOptions: err.response!.requestOptions,
            data: <String, dynamic>{
              'status': false,
              'message': ed.message,
              'error_code': ed.code,
              'raw': err.response!.data, // เก็บ payload เดิมไว้เพื่อดีบัก
            },
            statusCode: err.response!.statusCode,
            statusMessage: err.response!.statusMessage,
            headers: err.response!.headers,
            isRedirect: err.response!.isRedirect,
            redirects: err.response!.redirects,
            extra: Map<String, dynamic>.from(err.response!.extra),
          )
        : Response<Map<String, dynamic>>(
          requestOptions: err.requestOptions,
          statusCode: ed.code > 0 ? ed.code : null, // เช่น 408/499 หรือ -1 -> null
          data: <String, dynamic>{
            'status': false,
            'message': ed.message,
            'error_code': ed.code,
          },
        );

    // คงพฤติกรรม "เป็น error" ต่อไป
    handler.next(err.copyWith(response: shaped));

    // ถ้าอยากให้ไม่ throw แต่คืนค่าเป็น success:
    // handler.resolve(shaped);
  }
}