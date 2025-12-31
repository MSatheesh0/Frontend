/// User profile model for authentication and onboarding
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String primaryGoal;
  final String? company;
  final String? website;
  final String? location;
  final String? oneLiner;
  final String? phoneNumber;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.primaryGoal,
    this.company,
    this.website,
    this.location,
    this.oneLiner,
    this.phoneNumber,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'primaryGoal': primaryGoal,
        'company': company,
        'website': website,
        'location': location,
        'oneLiner': oneLiner,
        'phoneNumber': phoneNumber,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        primaryGoal: json['primaryGoal'] as String,
        company: json['company'] as String?,
        website: json['website'] as String?,
        location: json['location'] as String?,
        oneLiner: json['oneLiner'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? primaryGoal,
    String? company,
    String? website,
    String? location,
    String? oneLiner,
    String? phoneNumber,
  }) =>
      UserProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        primaryGoal: primaryGoal ?? this.primaryGoal,
        company: company ?? this.company,
        website: website ?? this.website,
        location: location ?? this.location,
        oneLiner: oneLiner ?? this.oneLiner,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        createdAt: createdAt,
      );
}

/// Result returned after OTP verification
class AuthResult {
  final bool isNewUser;
  final String authToken;
  final UserProfile? userProfile;

  AuthResult({
    required this.isNewUser,
    required this.authToken,
    this.userProfile,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        isNewUser: json['isNewUser'] as bool,
        authToken: json['authToken'] as String,
        userProfile: json['userProfile'] != null
            ? UserProfile.fromJson(json['userProfile'] as Map<String, dynamic>)
            : null,
      );
}

/// Role options for signup
class UserRole {
  // Display names (shown in UI)
  static const String founder = 'Founder / Co-founder';
  static const String investor = 'Investor / Angel';
  static const String mentor = 'Mentor / Advisor';
  static const String cxo = 'CXO / Leader';
  static const String serviceProvider = 'Service Provider / Agency';
  static const String other = 'Other';

  static List<String> get all => [
        founder,
        investor,
        mentor,
        cxo,
        serviceProvider,
        other,
      ];

  /// Convert display name to backend API value
  static String toApiValue(String displayName) {
    switch (displayName) {
      case founder:
        return 'founder';
      case investor:
        return 'investor';
      case mentor:
        return 'mentor';
      case cxo:
        return 'cxo';
      case serviceProvider:
        return 'service';
      case other:
        return 'other';
      default:
        return displayName; // For custom "other" text
    }
  }

  /// Convert backend API value to display name
  static String fromApiValue(String apiValue) {
    switch (apiValue) {
      case 'founder':
        return founder;
      case 'investor':
        return investor;
      case 'mentor':
        return mentor;
      case 'cxo':
        return cxo;
      case 'service':
        return serviceProvider;
      case 'other':
        return other;
      default:
        return apiValue; // For custom values
    }
  }
}

/// Primary goal options for signup
class PrimaryGoal {
  // Display names (shown in UI)
  static const String raiseFunds = 'Raise funds';
  static const String findClients = 'Find clients';
  static const String findCofounder = 'Find co-founder / team';
  static const String exploreOpportunities = 'Explore startup opportunities';
  static const String hireTalent = 'Hire or find talent';
  static const String learnConnect = 'Learn & connect';

  static List<String> get all => [
        raiseFunds,
        findClients,
        findCofounder,
        exploreOpportunities,
        hireTalent,
        learnConnect,
      ];

  /// Convert display name to backend API value
  static String toApiValue(String displayName) {
    switch (displayName) {
      case raiseFunds:
        return 'fundraising';
      case findClients:
        return 'clients';
      case findCofounder:
        return 'cofounder';
      case exploreOpportunities:
        return 'other';
      case hireTalent:
        return 'hiring';
      case learnConnect:
        return 'learn';
      default:
        return 'other';
    }
  }

  /// Convert backend API value to display name
  static String fromApiValue(String apiValue) {
    switch (apiValue) {
      case 'fundraising':
        return raiseFunds;
      case 'clients':
        return findClients;
      case 'cofounder':
        return findCofounder;
      case 'hiring':
        return hireTalent;
      case 'learn':
        return learnConnect;
      case 'other':
        return exploreOpportunities;
      default:
        return apiValue;
    }
  }
}
