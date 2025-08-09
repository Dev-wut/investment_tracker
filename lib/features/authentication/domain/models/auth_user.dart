import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
  });

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
  }) => AuthUser(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    photoUrl: photoUrl ?? this.photoUrl,
  );

  Map<String, String> toMap() => {
    'user_id': id,
    'user_email': email,
    'user_name': name ?? '',
    'user_photo_url': photoUrl ?? '',
  };

  static AuthUser? fromMap(Map<String, String> map) {
    final id = map['user_id'];
    final email = map['user_email'];
    if (id == null || email == null) return null;
    return AuthUser(
      id: id,
      email: email,
      name: map['user_name'],
      photoUrl: map['user_photo_url'],
    );
  }

  @override
  List<Object?> get props => [id, email, name, photoUrl];
}