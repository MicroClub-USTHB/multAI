class AccountEntity {
  final String name;
  final String email;
  final String? avatarUrl;

  const AccountEntity({
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}
