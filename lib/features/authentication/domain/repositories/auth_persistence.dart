import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';

abstract class IAuthPersistence {
  Future<void> saveUser(AuthUser user);
  Future<AuthUser?> readUser();
  Future<void> clear();
}

class AuthPersistenceImpl implements IAuthPersistence {
  static const _kId = 'user_id';
  static const _kEmail = 'user_email';
  static const _kName = 'user_name';
  static const _kPhoto = 'user_photo_url';

  @override
  Future<void> saveUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kId, user.id);
    await prefs.setString(_kEmail, user.email);
    await prefs.setString(_kName, user.name ?? '');
    await prefs.setString(_kPhoto, user.photoUrl ?? '');
  }

  @override
  Future<AuthUser?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, String>{
      _kId: prefs.getString(_kId) ?? '',
      _kEmail: prefs.getString(_kEmail) ?? '',
      _kName: prefs.getString(_kName) ?? '',
      _kPhoto: prefs.getString(_kPhoto) ?? '',
    };
    final user = AuthUser.fromMap(map);
    if (user == null) return null;
    if (user.id.isEmpty || user.email.isEmpty) return null;
    return user;
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kId);
    await prefs.remove(_kEmail);
    await prefs.remove(_kName);
    await prefs.remove(_kPhoto);
  }
}