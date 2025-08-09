part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class AuthenticateUser extends AuthEvent {
  final GoogleSignInAccount user;

  AuthenticateUser(this.user);

  @override
  List<Object?> get props => [user];
}

class SignOut extends AuthEvent {}

class ClearAuthState extends AuthEvent {}

class AuthError extends AuthEvent {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}