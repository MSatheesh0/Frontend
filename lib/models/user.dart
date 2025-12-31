class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? company;
  final String? bio;
  final String? avatarUrl;
  final String? location;
  final String? oneLiner;
  final String? website;
  final String? photoUrl;
  final String? phoneNumber;
  final List<String> interests;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.company,
    this.bio,
    this.avatarUrl,
    this.location,
    this.oneLiner,
    this.website,
    this.photoUrl,
    this.phoneNumber,
    this.interests = const [],
  });

  String get displayRole {
    if (company != null && company!.isNotEmpty) {
      return '$role at $company';
    }
    return role;
  }
  
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      company: map['company'],
      bio: map['oneLiner'] ?? map['bio'], // Handle both fields
      avatarUrl: map['photoUrl'] ?? map['avatarUrl'],
      location: map['location'],
      oneLiner: map['oneLiner'],
      website: map['website'],
      photoUrl: map['photoUrl'],
      phoneNumber: map['phoneNumber'],
      interests: List<String>.from(map['interests'] ?? []),
    );
  }
}
