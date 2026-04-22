import '../../domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.name,
    required super.email,
    super.avatarUrl,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : json;
    final email = (userJson['email'] as String?) ??
        (json['email'] as String?) ??
        '';
    final name = _deriveDisplayName(
      (json['name'] as String?) ??
          (userJson['name'] as String?) ??
          email,
    );

    return AccountModel(
      name: name,
      email: email,
      avatarUrl: (json['avatar_url'] as String?) ??
          (userJson['avatar_url'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'avatar_url': avatarUrl,
  };

  static String _deriveDisplayName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'User';

    final localPart = trimmed.contains('@')
        ? trimmed.split('@').first
        : trimmed;

    final normalized = localPart.replaceAll(RegExp(r'[._-]+'), ' ').trim();
    if (normalized.isEmpty) return 'User';

    return normalized
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
