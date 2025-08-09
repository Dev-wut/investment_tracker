part of 'google_auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class GoogleAuthState extends Equatable {
  final AuthStatus status;
  final AuthUser? user;
  final String? error;

  const GoogleAuthState._(this.status, {this.user, this.error});

  const GoogleAuthState.initial() : this._(AuthStatus.initial);
  const GoogleAuthState.loading() : this._(AuthStatus.loading);
  const GoogleAuthState.unauthenticated() : this._(AuthStatus.unauthenticated);
  const GoogleAuthState.failure(String e) : this._(AuthStatus.failure, error: e);
  const GoogleAuthState.authenticated(AuthUser u) : this._(AuthStatus.authenticated, user: u);

  @override
  List<Object?> get props => [status, user, error];
}