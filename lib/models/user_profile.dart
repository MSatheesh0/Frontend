class UserProfile {
  final String userId;
  final String displayName;
  final String? headline; // short tagline like "AI founder in SaaS"
  final String? aiSummary; // paragraph summary built from chats
  final List<String>
      currentFocus; // e.g. ["Raising pre-seed", "Looking for pilot partners"]
  final List<String>
      strengths; // optional highlights like ["Built TrackSense.ai", "10+ years in mobile & backend"]
  final List<ProfileDoc> docs; // attached docs/links
  final DateTime lastUpdated;

  UserProfile({
    required this.userId,
    required this.displayName,
    this.headline,
    this.aiSummary,
    required this.currentFocus,
    required this.strengths,
    required this.docs,
    required this.lastUpdated,
  });

  UserProfile copyWith({
    String? displayName,
    String? headline,
    String? aiSummary,
    List<String>? currentFocus,
    List<String>? strengths,
    List<ProfileDoc>? docs,
    DateTime? lastUpdated,
  }) {
    return UserProfile(
      userId: userId,
      displayName: displayName ?? this.displayName,
      headline: headline ?? this.headline,
      aiSummary: aiSummary ?? this.aiSummary,
      currentFocus: currentFocus ?? this.currentFocus,
      strengths: strengths ?? this.strengths,
      docs: docs ?? this.docs,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class ProfileDoc {
  final String id;
  final String title; // e.g. "Pitch Deck v1"
  final String type; // e.g. "pdf", "link"
  final String urlOrPath; // link or local path
  final String? description;

  ProfileDoc({
    required this.id,
    required this.title,
    required this.type,
    required this.urlOrPath,
    this.description,
  });
}
