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
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      company: map['company']?.toString(), // Explicit conversion
      bio: (map['oneLiner'] ?? map['bio'])?.toString(),
      avatarUrl: (map['photoUrl'] ?? map['avatarUrl'])?.toString(),
      location: map['location']?.toString(), // Explicit conversion
      oneLiner: map['oneLiner']?.toString(),
      website: map['website']?.toString(),
      photoUrl: map['photoUrl']?.toString(),
      phoneNumber: map['phoneNumber']?.toString(),
      interests: List<String>.from(map['interests'] ?? []),
    );
  }
}
