class User {
  final String id;
  final String name;
  final String role;
  final String? company;
  final String? bio;
  final String? avatarUrl;
  final List<String> interests;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.company,
    this.bio,
    this.avatarUrl,
    this.interests = const [],
  });

  String get displayRole {
    if (company != null && company!.isNotEmpty) {
      return '$role at $company';
    }
    return role;
  }
}
