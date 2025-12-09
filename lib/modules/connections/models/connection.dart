class Connection {
  final String id;
  final String userId;
  final String name;
  final String role;
  final String? company;
  final String? avatarUrl;
  final DateTime connectedAt;
  final ConnectionType type;
  final List<String> sharedInterests;

  Connection({
    required this.id,
    required this.userId,
    required this.name,
    required this.role,
    this.company,
    this.avatarUrl,
    required this.connectedAt,
    required this.type,
    this.sharedInterests = const [],
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['userId2'] ?? '', // Assuming userId2 is the other person if we are userId1
      name: json['name'] ?? 'Unknown', // Backend might not send name directly in connection object, need to check
      role: json['role'] ?? '',
      company: json['company'],
      avatarUrl: json['avatarUrl'] ?? json['photoUrl'],
      connectedAt: DateTime.tryParse(json['connectedAt'] ?? '') ?? DateTime.now(),
      type: _parseConnectionType(json['status'] ?? ''),
      sharedInterests: (json['sharedInterests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  static ConnectionType _parseConnectionType(String status) {
    switch (status) {
      case 'connected':
        return ConnectionType.innerCircle; // Mapping connected to innerCircle for now
      case 'pending':
        return ConnectionType.pending;
      default:
        return ConnectionType.suggested;
    }
  }

  String get displayRole {
    if (company != null && company!.isNotEmpty) {
      return '$role at $company';
    }
    return role;
  }
}

enum ConnectionType {
  innerCircle,
  pending,
  suggested,
}
