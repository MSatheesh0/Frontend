/// Base model for a person added via Network Code scan
class TaggedPerson {
  final String id;
  final String label; // display name: "Arjun", "BlueStone Capital"
  final String networkCodeId; // which Network Code / circle they came from
  final List<String> userTags;

  TaggedPerson({
    required this.id,
    required this.label,
    required this.networkCodeId,
    required this.userTags,
  });
}

/// A connection made via Network Code scan
class Connection extends TaggedPerson {
  Connection({
    required super.id,
    required super.label,
    required super.networkCodeId,
    required super.userTags,
  });
}

/// A following added via Network Code scan
class FollowingPerson extends TaggedPerson {
  FollowingPerson({
    required super.id,
    required super.label,
    required super.networkCodeId,
    required super.userTags,
  });
}
