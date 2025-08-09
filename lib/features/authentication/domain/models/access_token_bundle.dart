class AccessTokenBundle {
  final String accessToken;
  final List<String> scopes; // scopes granted for this token
  final DateTime obtainedAt; // when acquired; helps soft-expiration on web

  const AccessTokenBundle({
    required this.accessToken,
    required this.scopes,
    required this.obtainedAt,
  });

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'scopes': scopes,
    'obtainedAt': obtainedAt.toIso8601String(),
  };

  static AccessTokenBundle? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final token = json['accessToken'] as String?;
    final scopes = (json['scopes'] as List?)?.cast<String>() ?? const <String>[];
    final obtainedAtStr = json['obtainedAt'] as String?;
    if (token == null || token.isEmpty || obtainedAtStr == null) return null;
    return AccessTokenBundle(
      accessToken: token,
      scopes: scopes,
      obtainedAt: DateTime.parse(obtainedAtStr),
    );
  }
}