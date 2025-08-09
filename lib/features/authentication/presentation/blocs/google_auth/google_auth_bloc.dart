import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../domain/models/auth_user.dart';
import '../../../domain/repositories/google_auth_repository.dart';

part 'google_auth_event.dart';
part 'google_auth_state.dart';

class GoogleAuthBloc extends Bloc<GoogleAuthEvent, GoogleAuthState> {

  final GoogleAuthRepository _repo;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _sub;

  GoogleAuthBloc(this._repo) : super(const GoogleAuthState.initial()) {
    on<GoogleAuthStarted>(_onStarted);
    on<GoogleAuthSignInRequested>(_onSignInRequested);
    on<GoogleAuthSignOutRequested>(_onSignOutRequested);

    // Handle internal stream-to-state mapping here
    on<_AuthChanged>((e, emit) {
      if (e.user != null) {
        emit(GoogleAuthState.authenticated(e.user!));
      } else {
        emit(const GoogleAuthState.unauthenticated());
      }
    });

    // Mirror google_sign_in authentication events into internal BLoC events (do NOT emit here)
    _sub = GoogleSignIn.instance.authenticationEvents.listen((event) async {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        final u = AuthUser(
          id: event.user.id,
          email: event.user.email,
          name: event.user.displayName,
          photoUrl: event.user.photoUrl,
        );
        add(_AuthChanged(u));
      } else if (event is GoogleSignInAuthenticationEventSignOut) {
        add(const _AuthChanged(null));
      }
    });
  }

  Future<void> _onStarted(GoogleAuthStarted e, Emitter<GoogleAuthState> emit) async {
    emit(const GoogleAuthState.loading());
    log("onStarted");
    try {
      await _repo.initialize(clientId: e.clientId, serverClientId: e.serverClientId);
      final user = await _repo.readPersistedUser();
      if (user != null) {
        emit(GoogleAuthState.authenticated(user));
      } else {
        // Wait a moment for attemptLightweightAuthentication to possibly emit
        await Future<void>.delayed(const Duration(milliseconds: 200));
        emit(const GoogleAuthState.unauthenticated());
      }
    } catch (err) {
      emit(GoogleAuthState.failure(err.toString()));
    }
  }
  Future<void> _onSignInRequested(GoogleAuthSignInRequested e, Emitter<GoogleAuthState> emit) async {
    emit(const GoogleAuthState.loading());
    try {
      final acc = await _repo.signIn();
      if (acc == null) {
        emit(const GoogleAuthState.failure('ยกเลิกการเข้าสู่ระบบ'));
      }
      // Success path is driven by authenticationEvents listener
    } on GoogleSignInException {
      emit(GoogleAuthState.failure('ยกเลิกการเข้าสู่ระบบ'));
    } catch (err) {
      emit(GoogleAuthState.failure('$err'));
    }
  }

  Future<void> _onSignOutRequested(GoogleAuthSignOutRequested e, Emitter<GoogleAuthState> emit) async {
    emit(const GoogleAuthState.loading());
    try {
      await _repo.signOut(disconnect: e.disconnect);
      emit(const GoogleAuthState.unauthenticated());
    } catch (err) {
      emit(GoogleAuthState.failure('$err'));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    _repo.dispose();
    return super.close();
  }
}
