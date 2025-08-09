import 'dart:async';
import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/app_constants.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignIn _googleSignIn;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;

  AuthBloc({
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        super(AuthInitial()) {

    // Register all event handlers
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<AuthenticateUser>(_onAuthenticateUser);
    on<SignOut>(_onSignOut);
    on<ClearAuthState>(_onClearAuthState);
    on<AuthError>(_onAuthError);

    // Initialize authentication
    _initializeAuth();
  }

  void _initializeAuth() async {
    // Initialize Google Sign-In
    unawaited(_googleSignIn
        .initialize(
      clientId: AppConstants.iosClientId,
      serverClientId: AppConstants.serverClientId,
    )
        .then((_) {
      _authSubscription = _googleSignIn.authenticationEvents
          .listen(_handleAuthenticationEvent);

      _authSubscription!.onError(_handleAuthenticationError);

      // Check before attempting lightweight authentication
      if (AppConstants.serverClientId.isNotEmpty) {
        _googleSignIn.attemptLightweightAuthentication();
      }

      // Also trigger manual auth check
      add(CheckAuthStatus());
    }).catchError((error) {
      dev.log('Failed to initialize Google Sign-In: $error');
      add(AuthError('Failed to initialize: ${error.toString()}'));
    }));
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        add(AuthenticateUser(event.user));
        break;
      case GoogleSignInAuthenticationEventSignOut():
        add(ClearAuthState());
        break;
    }
  }

  void _handleAuthenticationError(Object error) {
    dev.log('Authentication error: $error');
    add(AuthError('Authentication error occurred'));
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event,
      Emitter<AuthState> emit,
      ) async {
    try {
      emit(AuthLoading());

      // Check if user is stored in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userEmail = prefs.getString('user_email');

      if (userId != null && userEmail != null) {
        // Try silent sign-in first
        try {
          final user = await _googleSignIn.attemptLightweightAuthentication();
          if (user != null && user.id == userId) {
            emit(AuthAuthenticated(user));
            return;
          }
        } catch (e) {
          dev.log('Silent sign-in failed: $e');
        }

        // Clear invalid stored data
        await _clearStoredUserData();
        emit(AuthUnauthenticated());
      } else {
        // No stored user, try silent sign-in anyway
        try {
          final user = await _googleSignIn.attemptLightweightAuthentication();
          if (user != null) {
            await _storeUserData(user);
            emit(AuthAuthenticated(user));
          } else {
            emit(AuthUnauthenticated());
          }
        } catch (e) {
          dev.log('Silent sign-in failed: $e');
          emit(AuthUnauthenticated());
        }
      }
    } catch (e) {
      dev.log('Error checking auth status: $e');
      emit(AuthErrorState('Failed to check authentication status'));
    }
  }

  Future<void> _onAuthenticateUser(
      AuthenticateUser event,
      Emitter<AuthState> emit,
      ) async {
    try {
      // Store user data in SharedPreferences
      await _storeUserData(event.user);
      emit(AuthAuthenticated(event.user));
    } catch (e) {
      dev.log('Error authenticating user: $e');
      emit(AuthErrorState('Failed to authenticate user'));
    }
  }

  Future<void> _onSignOut(
      SignOut event,
      Emitter<AuthState> emit,
      ) async {
    try {
      emit(AuthLoading());

      // Sign out from Google
      await _googleSignIn.disconnect();

      // Clear stored user data
      await _clearStoredUserData();

      emit(AuthUnauthenticated());
    } catch (e) {
      dev.log('Error signing out: $e');
      emit(AuthErrorState('Failed to sign out'));
    }
  }

  Future<void> _onClearAuthState(
      ClearAuthState event,
      Emitter<AuthState> emit,
      ) async {
    try {
      // Clear stored user data
      await _clearStoredUserData();
      emit(AuthUnauthenticated());
    } catch (e) {
      dev.log('Error clearing auth state: $e');
      emit(AuthErrorState('Failed to clear authentication state'));
    }
  }

  Future<void> _onAuthError(
      AuthError event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthErrorState(event.message));
  }

  // Helper method to store user data
  Future<void> _storeUserData(GoogleSignInAccount user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_name', user.displayName ?? '');
      await prefs.setString('user_photo_url', user.photoUrl ?? '');

      dev.log('User data stored successfully');
    } catch (e) {
      dev.log('Error storing user data: $e');
      rethrow;
    }
  }

  // Helper method to clear stored user data
  Future<void> _clearStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_photo_url');

      dev.log('User data cleared successfully');
    } catch (e) {
      dev.log('Error clearing user data: $e');
    }
  }

  // Getters for current user data
  GoogleSignInAccount? get currentUser {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      return currentState.user;
    }
    return null;
  }

  bool get isAuthenticated {
    return state is AuthAuthenticated;
  }

  bool get isLoading {
    return state is AuthLoading;
  }

  bool get hasError {
    return state is AuthErrorState;
  }

  String? get errorMessage {
    final currentState = state;
    if (currentState is AuthErrorState) {
      return currentState.message;
    }
    return null;
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}