import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../features/authentication/domain/models/google_scopes.dart';
import '../../features/authentication/domain/repositories/google_auth_repository.dart';

class AppScriptApiClient {
  final GoogleAuthRepository _authRepo;
  final http.Client _http;
  final Uri baseExecUrl; // e.g. https://script.google.com/macros/s/DEPLOYMENT_ID/exec

  AppScriptApiClient({
    required GoogleAuthRepository authRepo,
    required this.baseExecUrl,
    http.Client? httpClient,
  })  : _authRepo = authRepo,
        _http = httpClient ?? http.Client();

  static const _scopes = GoogleScopes.appsScript;

  Future<http.Response> get({Map<String, String>? query}) async {
    final uri = baseExecUrl.replace(queryParameters: query);
    return _send(() => http.Request('GET', uri));
  }

  Future<http.Response> postJson(Map<String, dynamic> body) async {
    return _send(() {
      final req = http.Request('POST', baseExecUrl);
      req.headers['content-type'] = 'application/json';
      req.body = jsonEncode(body);
      return req;
    });
  }

  Future<http.Response> _send(http.Request Function() build) async {
    String token = await _authRepo.getAccessToken(scopes: _scopes);
    http.Response res = await _dispatch(build(), token);

    if (res.statusCode == 401 || res.statusCode == 403) {
      // Re-authorize and retry once
      token = await _authRepo.getAccessToken(scopes: _scopes, softTtlMinutes: 0);
      res = await _dispatch(build(), token);
    }
    return res;
  }

  Future<http.Response> _dispatch(http.Request req, String token) async {
    req.headers['authorization'] = 'Bearer $token';
    final streamed = await _http.send(req);
    return http.Response.fromStream(streamed);
  }

  void close() => _http.close();
}