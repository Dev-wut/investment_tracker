import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../../core/constants/app_constants.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final GoogleSignIn _googleSignIn;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;

  /// The scopes required by this application
  static const List<String> scopes = <String>[
    'email',
    'profile',
  ];

  LoginBloc({
    GoogleSignIn? googleSignIn,
    String? clientId,
    String? serverClientId,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        super(LoginInitial()) {

    // Register all event handlers
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<_AuthenticationSuccess>(_onAuthenticationSuccess);
    on<_AuthenticationSignOut>(_onAuthenticationSignOut);
    on<_AuthenticationError>(_onAuthenticationError);

    // Initialize Google Sign-In ใช้ค่าจาก AppConstants
    _initializeGoogleSignIn(
      clientId ?? AppConstants.iosClientId,        // iOS Client ID
      serverClientId ?? AppConstants.serverClientId, // Android Server Client ID
    );
  }

  void _initializeGoogleSignIn(String? clientId, String? serverClientId) {
    unawaited(_googleSignIn
        .initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    )
        .then((_) {
      _authSubscription = _googleSignIn.authenticationEvents
          .listen(_handleAuthenticationEvent);

      _authSubscription!.onError(_handleAuthenticationError);

      // เช็คก่อนทำ silent sign-in
      if (serverClientId != null && serverClientId.isNotEmpty) {
        _googleSignIn.attemptLightweightAuthentication();
      }
    }).catchError((error) {
      // จัดการ error ตอน initialize
      add(_AuthenticationError('Failed to initialize: ${error.toString()}'));
    }));
  }

  // Stream handlers - convert to BLoC events (NO emit() calls here)
  Future<void> _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        add(_AuthenticationSuccess(event.user));
        break;
      case GoogleSignInAuthenticationEventSignOut():
        add(_AuthenticationSignOut());
        break;
    }
  }

  Future<void> _handleAuthenticationError(Object error) async {
    final String errorMessage = error is GoogleSignInException
        ? _errorMessageFromSignInException(error)
        : 'Unknown authentication error: $error';

    add(_AuthenticationError(errorMessage));
  }

  // Event handlers - ONLY place where emit() is called
  Future<void> _onGoogleSignInRequested(
      GoogleSignInRequested event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginLoading());

    try {
      if (_googleSignIn.supportsAuthenticate()) {
        await _googleSignIn.authenticate();
        // Result handled by stream -> event -> emit cycle
      } else {
        emit(LoginFailure(error: 'Authentication not supported on this platform'));
      }
    } on GoogleSignInException catch (e) {
      emit(LoginFailure(error: _errorMessageFromSignInException(e)));
    } catch (e) {
      emit(LoginFailure(error: 'Failed to sign in with Google: ${e.toString()}'));
    }
  }

  Future<void> _onSignOutRequested(
      SignOutRequested event,
      Emitter<LoginState> emit,
      ) async {
    try {
      await _googleSignIn.disconnect();
      // Result handled by stream -> event -> emit cycle
    } on GoogleSignInException catch (e) {
      emit(LoginFailure(error: _errorMessageFromSignInException(e)));
    } catch (e) {
      emit(LoginFailure(error: 'Failed to sign out: ${e.toString()}'));
    }
  }

  // Internal event handlers - handle stream results
  Future<void> _onAuthenticationSuccess(
      _AuthenticationSuccess event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginSuccess(user: event.user));
  }

  Future<void> _onAuthenticationSignOut(
      _AuthenticationSignOut event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginInitial());
  }

  Future<void> _onAuthenticationError(
      _AuthenticationError event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginFailure(error: event.error));
  }

  String _errorMessageFromSignInException(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'ยกเลิกการเข้าสู่ระบบ',
      GoogleSignInExceptionCode.interrupted => 'การเข้าสู่ระบบถูกขัดจังหวะ กรุณาลองใหม่',
      GoogleSignInExceptionCode.clientConfigurationError => 'การตั้งค่า Google Sign-In ไม่ถูกต้อง กรุณาติดต่อผู้พัฒนา',
      GoogleSignInExceptionCode.providerConfigurationError => 'บริการยืนยันตัวตนไม่พร้อมใช้งาน กรุณาลองใหม่ภายหลัง',
      GoogleSignInExceptionCode.uiUnavailable => 'ไม่สามารถแสดงหน้าเข้าสู่ระบบได้ กรุณาลองใหม่',
      GoogleSignInExceptionCode.userMismatch => 'ตรวจพบบัญชีไม่ตรงกัน กรุณาออกจากระบบและเข้าใหม่',
      GoogleSignInExceptionCode.unknownError => 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ',
    };
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
