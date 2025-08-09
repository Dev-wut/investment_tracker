import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/access_token_bundle.dart';

abstract class ISecureTokenStorage {
  Future<void> saveForKey(String key, AccessTokenBundle bundle);
  Future<AccessTokenBundle?> readForKey(String key);
  Future<void> clearForKey(String key);
}

class SecureTokenStorageImpl implements ISecureTokenStorage {
  final FlutterSecureStorage _storage;

  SecureTokenStorageImpl([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveForKey(String key, AccessTokenBundle bundle) async {
    await _storage.write(key: key, value: jsonEncode(bundle.toJson()));
  }

  @override
  Future<AccessTokenBundle?> readForKey(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return null;
    return AccessTokenBundle.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> clearForKey(String key) async {
    await _storage.delete(key: key);
  }
}