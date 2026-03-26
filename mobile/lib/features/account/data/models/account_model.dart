import '../../domain/entities/account_entity.dart';

class AccountModel extends AccountEntity {
  const AccountModel({
    required super.name,
    required super.email,
    required super.membershipType,
    super.avatarUrl,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      name: json['name'] as String,
      email: json['email'] as String,
      membershipType: json['membership_type'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'membership_type': membershipType,
        'avatar_url': avatarUrl,
      };
}
