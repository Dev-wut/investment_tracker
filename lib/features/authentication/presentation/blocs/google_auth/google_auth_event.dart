part of 'google_auth_bloc.dart';

sealed class GoogleAuthEvent extends Equatable {
  const GoogleAuthEvent();
  @override
  List<Object?> get props => [];
}

class GoogleAuthStarted extends GoogleAuthEvent {
  final String? clientId;        // iOS client ID
  final String? serverClientId;  // Web client ID (for server auth code if needed)
  const GoogleAuthStarted({this.clientId, this.serverClientId});
}

class GoogleAuthSignInRequested extends GoogleAuthEvent {
  const GoogleAuthSignInRequested();
}

class GoogleAuthSignOutRequested extends GoogleAuthEvent {
  final bool disconnect; // true => revoke
  const GoogleAuthSignOutRequested({this.disconnect = false});
}

class _AuthChanged extends GoogleAuthEvent {
  final AuthUser? user;
  const _AuthChanged(this.user);

  @override
  List<Object?> get props => [user];
}
