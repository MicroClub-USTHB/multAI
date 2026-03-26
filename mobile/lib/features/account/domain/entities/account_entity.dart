class AccountEntity {
  final String name;
  final String email;
  final String membershipType;
  final String? avatarUrl;

  const AccountEntity({
    required this.name,
    required this.email,
    required this.membershipType,
    this.avatarUrl,
  });
}
