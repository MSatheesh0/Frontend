class AppNotification {
  final String id;
  final String actorId;
  final String actorName;
  final String? actorPhotoUrl;
  final String eventId;
  final String eventName;
  final String type;
  final DateTime createdAt;
  bool isRead;
  bool isDismissed;

  AppNotification({
    required this.id,
    required this.actorId,
    required this.actorName,
    this.actorPhotoUrl,
    required this.eventId,
    required this.eventName,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.isDismissed = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final actor = json['actorId'] ?? {};
    final event = json['eventId'] ?? {};
    
    return AppNotification(
      id: json['_id'] ?? '',
      actorId: actor['_id'] ?? '',
      actorName: (actor['name'] as String?) ?? (json['externalActorName'] as String?) ?? 'Unknown User',
      actorPhotoUrl: actor['photoUrl'],
      eventId: event['_id'] ?? '',
      eventName: event['name'] ?? 'Unknown Event',
      type: json['type'] ?? 'EVENT_JOIN',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      isDismissed: json['isDismissed'] ?? false,
    );
  }
}
