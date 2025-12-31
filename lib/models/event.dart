class Event {
  final String id;
  final String name;
  final String? headline; // Event tagline/headline
  final String description;
  final DateTime dateTime;
  final String location;
  final String? imageUrl;
  final bool isJoined;

  // Media
  final List<String> photos; // List of photo URLs
  final List<String> videos; // List of video URLs
  final List<String> tags; // Event tags

  // Relevance data
  final String? matchReason; // Why this event is relevant
  final String? matchLevel; // "High match", "Medium match", or percentage
  final int? matchPercentage; // 0-100
  final bool isPrimaryRecommendation; // Top curated vs "other circles"
  final List<String> attendees; // List of user IDs who joined
  final bool isEvent;
  final bool isCommunity;
  final bool isVerified; // Verified by admin
  final bool isDismissed; // User marked "Not interested"

  Event({
    required this.id,
    required this.name,
    this.headline,
    required this.description,
    required this.dateTime,
    required this.location,
    this.imageUrl,
    this.isEvent = true,
    this.isCommunity = false,
    this.isVerified = false,
    this.isJoined = false,
    this.attendees = const [],
    this.photos = const [],
    this.videos = const [],
    this.tags = const [],
    this.matchReason,
    this.matchLevel,
    this.matchPercentage,
    this.isPrimaryRecommendation = false,
    this.isDismissed = false,
  });

  Event copyWith({
    String? id,
    String? name,
    String? headline,
    String? description,
    DateTime? dateTime,
    String? location,
    String? imageUrl,
    bool? isEvent,
    bool? isCommunity,
    bool? isVerified,
    bool? isJoined,
    List<String>? attendees,
    List<String>? photos,
    List<String>? videos,
    List<String>? tags,
    String? matchReason,
    String? matchLevel,
    int? matchPercentage,
    bool? isPrimaryRecommendation,
    bool? isDismissed,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      headline: headline ?? this.headline,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      isEvent: isEvent ?? this.isEvent,
      isCommunity: isCommunity ?? this.isCommunity,
      isVerified: isVerified ?? this.isVerified,
      isJoined: isJoined ?? this.isJoined,
      attendees: attendees ?? this.attendees,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      tags: tags ?? this.tags,
      matchReason: matchReason ?? this.matchReason,
      matchLevel: matchLevel ?? this.matchLevel,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      isPrimaryRecommendation:
          isPrimaryRecommendation ?? this.isPrimaryRecommendation,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}

class EventCircle {
  final String id;
  final String eventId;
  final String eventName;
  final DateTime joinedAt;
  final List<String> memberIds;

  EventCircle({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.joinedAt,
    this.memberIds = const [],
  });
}
