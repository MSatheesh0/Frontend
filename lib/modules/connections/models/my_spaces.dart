// Model for Network Code Groups (user-created)
class NetworkCodeGroup {
  final String id;
  final String name;
  final String code;
  final int memberCount;
  final DateTime createdAt;
  final String? description;

  NetworkCodeGroup({
    required this.id,
    required this.name,
    required this.code,
    required this.memberCount,
    required this.createdAt,
    this.description,
  });
}

// Model for Circles (event/context-based)
class Circle {
  final String id;
  final String name;
  final CircleType type;
  final int memberCount;
  final DateTime joinedAt;
  final String? description;
  final List<String> tags;

  Circle({
    required this.id,
    required this.name,
    required this.type,
    required this.memberCount,
    required this.joinedAt,
    this.description,
    this.tags = const [],
  });
}

enum CircleType {
  event,
  interest,
  industry,
  location,
}

extension CircleTypeExtension on CircleType {
  String get displayName {
    switch (this) {
      case CircleType.event:
        return 'Event';
      case CircleType.interest:
        return 'Interest';
      case CircleType.industry:
        return 'Industry';
      case CircleType.location:
        return 'Location';
    }
  }
}

// Unified view model for "My Spaces"
class MySpace {
  final String id;
  final String name;
  final SpaceType type;
  final int memberCount;
  final String? subtitle;
  final List<String> tags;

  MySpace({
    required this.id,
    required this.name,
    required this.type,
    required this.memberCount,
    this.subtitle,
    this.tags = const [],
  });

  factory MySpace.fromNetworkCode(NetworkCodeGroup networkCode) {
    return MySpace(
      id: networkCode.id,
      name: networkCode.name,
      type: SpaceType.networkCode,
      memberCount: networkCode.memberCount,
      subtitle: networkCode.code,
      tags: [],
    );
  }

  factory MySpace.fromCircle(Circle circle) {
    return MySpace(
      id: circle.id,
      name: circle.name,
      type: SpaceType.circle,
      memberCount: circle.memberCount,
      subtitle: circle.type.displayName,
      tags: circle.tags,
    );
  }
}

enum SpaceType {
  networkCode,
  circle,
}
