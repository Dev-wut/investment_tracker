part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Public events (from UI)
class GoogleSignInRequested extends LoginEvent {}

class SignOutRequested extends LoginEvent {}

// Internal events (from streams) - these need handlers!
class _AuthenticationSuccess extends LoginEvent {
  final GoogleSignInAccount user;

  _AuthenticationSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class _AuthenticationSignOut extends LoginEvent {}

class _AuthenticationError extends LoginEvent {
  final String error;

  _AuthenticationError(this.error);

  @override
  List<Object?> get props => [error];
}