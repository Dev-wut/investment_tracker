import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';

import '../models/access_token_bundle.dart';
import '../models/auth_user.dart';
import '../models/token_keys.dart';
import 'auth_persistence.dart';
import 'secure_token_storage.dart';

class GoogleAuthRepository {
  final IAuthPersistence _persistence;
  final ISecureTokenStorage _tokenStorage;

  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSub;

  // Keep the most recent signed-in account in memory
  GoogleSignInAccount? _current;

  GoogleAuthRepository(this._persistence, this._tokenStorage);

  GoogleSignIn get _gs => GoogleSignIn.instance;

  Future<void> initialize({String? clientId, String? serverClientId}) async {
    await _gs.initialize(clientId: clientId, serverClientId: serverClientId);
    _authSub?.cancel();
    _authSub = _gs.authenticationEvents.listen(_onAuthEvent, onError: _onAuthError);

    // Try lightweight, may set current user without UI
    // await _gs.attemptLightweightAuthentication();
    // final account = await _gs.attemptLightweightAuthentication();
    // if (account != null) {
    //   _current = account;
    //   final authUser = AuthUser(
    //     id: account.id,
    //     email: account.email,
    //     name: account.displayName,
    //     photoUrl: account.photoUrl,
    //   );
    //   await _persistence.saveUser(authUser);
    // }
  }

  void dispose() {
    _authSub?.cancel();
  }

  void _onAuthEvent(GoogleSignInAuthenticationEvent event) async {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn(:final user):
        _current = user;
        final authUser = AuthUser(
          id: user.id,
          email: user.email,
          name: user.displayName,
          photoUrl: user.photoUrl,
        );
        await _persistence.saveUser(authUser);
        break;
      case GoogleSignInAuthenticationEventSignOut():
        _current = null;
        await _persistence.clear();
        // Optionally clear tokens
        await _tokenStorage.clearForKey(TokenKeys.appsScript);
        break;
    }
  }

  void _onAuthError(Object error) {
    // no-op here; Bloc will surface errors on calls
  }

  Future<AuthUser?> readPersistedUser() => _persistence.readUser();

  Future<GoogleSignInAccount?> signIn() async {
    if (_gs.supportsAuthenticate()) {
      final acc = await _gs.authenticate();
      _current = acc;
      return acc;
    }
    // else: platform-specific fallback, not covered here
    return null;
  }

  Future<void> signOut({bool disconnect = false}) async {
    if (disconnect) {
      await _gs.disconnect(); // revokes
    } else {
      await _gs.signOut();
    }
    _current = null;
    await _persistence.clear();
    await _tokenStorage.clearForKey(TokenKeys.appsScript);
  }

  /// Get ID token (for Firebase/your backend identity)
  Future<String?> getIdToken() async {
    var acc = _current;
    acc ??= await _gs.attemptLightweightAuthentication();
    if (acc == null) return null;
    _current = acc;
    final auth = acc.authentication;
    return auth.idToken;
  }

  /// Acquire an access token for given [scopes].
  /// If we have a recent token in secure storage, reuse it.
  /// On web tokens expire ~1h; use [softTtlMinutes] to decide when to refresh.
  Future<String> getAccessTokenV0({
    required List<String> scopes,
    String storageKey = TokenKeys.appsScript,
    int softTtlMinutes = 50,
  }) async {
    final now = DateTime.now();
    final cached = await _tokenStorage.readForKey(storageKey);
    if (cached != null) {
      final age = now.difference(cached.obtainedAt).inMinutes;
      final sameScopes = _sameScopeSet(scopes, cached.scopes);
      if (sameScopes && age < softTtlMinutes) {
        return cached.accessToken;
      }
    }

    var acc = _current;
    acc ??= await _gs.attemptLightweightAuthentication();
    if (acc == null) {
      throw StateError('Not signed in');
    }

    // Try silently first
    final maybe = await acc.authorizationClient.authorizationForScopes(scopes);
    final token = maybe?.accessToken ??
        (await acc.authorizationClient.authorizeScopes(scopes)).accessToken;

    await _tokenStorage.saveForKey(
      storageKey,
      AccessTokenBundle(accessToken: token, scopes: scopes, obtainedAt: now),
    );
    return token;
  }

  Future<String> getAccessToken({
    required List<String> scopes,
    String storageKey = TokenKeys.appsScript,
    int softTtlMinutes = 50,
  }) async {
    final now = DateTime.now();

    // 1) ใช้ token ที่ cache ไว้ (ยังไม่หมดอายุแบบ soft TTL)
    final cached = await _tokenStorage.readForKey(storageKey);
    if (cached != null) {
      final age = now.difference(cached.obtainedAt).inMinutes;
      final sameScopes = _sameScopeSet(scopes, cached.scopes);
      if (sameScopes && age < softTtlMinutes) {
        return cached.accessToken;
      }
    }

    // 2) ต้องมี account ก่อน
    var acc = _current ?? await _gs.attemptLightweightAuthentication();
    if (acc == null) {
      throw StateError('Not signed in');
    }

    // 3) ขอสิทธิ์ → ผู้ใช้ “อาจ” ยกเลิกได้ → จับ exception เป็นกรณีพิเศษ
    try {
      final maybe = await acc.authorizationClient.authorizationForScopes(scopes);
      final token = maybe?.accessToken
          ?? (await acc.authorizationClient.authorizeScopes(scopes)).accessToken;

      await _tokenStorage.saveForKey(
        storageKey,
        AccessTokenBundle(accessToken: token, scopes: scopes, obtainedAt: now),
      );
      return token;
    } on GoogleSignInException catch (e) {
      if (_isUserCancelledGoogleException(e)) {
        // โยนเป็นเคสยกเลิกให้ UI จัดการแบบนุ่มนวล
        throw const AuthzCancelledException();
      }
      rethrow; // อย่างอื่นให้เด้งตามจริง
    }
  }



  bool _sameScopeSet(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sa = a.toSet();
    final sb = b.toSet();
    return sa.length == sb.length && sa.containsAll(sb);
  }
}

class AuthzCancelledException implements Exception {
  final String message;
  const AuthzCancelledException([this.message = 'User cancelled authorization']);
  @override
  String toString() => 'AuthzCancelledException: $message';
}

bool _isUserCancelledGoogleException(GoogleSignInException e) {
  // Play Services code 16 = CANCELED; บางแพลตฟอร์มส่งมาเป็น unknownError พร้อมข้อความ
  final s = e.toString();
  return e.code == GoogleSignInExceptionCode.unknownError && (
      s.contains('Cancelled by user') ||
          s.contains('CANCELED') ||
          s.contains('[16]') ||
          s.contains('User canceled')
  );
}