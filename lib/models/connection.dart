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
  
  // Backend-specific fields
  final String? networkCodeId;
  final String? codeId;
  final String? requestorId;
  final String? ownerId; // The network code owner
  final String status; // pending, accepted, rejected
  final bool autoConnected;

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
    this.networkCodeId,
    this.codeId,
    this.requestorId,
    this.ownerId,
    this.status = 'accepted',
    this.autoConnected = false,
  });

  /// Factory constructor to create Connection from backend API response
  factory Connection.fromBackendJson(Map<String, dynamic> json, String currentUserId) {
    // Determine which user is the "other" user in the connection
    final requestorData = json['requestorId'] as Map<String, dynamic>?;
    final ownerData = json['userId'] as Map<String, dynamic>?;
    
    // If current user is the requestor, show the owner's details
    // If current user is the owner, show the requestor's details
    final isCurrentUserRequestor = requestorData?['_id'] == currentUserId;
    final otherUser = isCurrentUserRequestor ? ownerData : requestorData;
    
    final status = json['status'] as String? ?? 'pending';
    ConnectionType type;
    if (status == 'accepted') {
      type = ConnectionType.innerCircle;
    } else if (status == 'pending') {
      type = ConnectionType.pending;
    } else {
      type = ConnectionType.suggested;
    }

    return Connection(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      userId: otherUser?['_id'] as String? ?? otherUser?['id'] as String? ?? '',
      name: otherUser?['name'] as String? ?? 'Unknown',
      role: otherUser?['role'] as String? ?? '',
      company: otherUser?['company'] as String?,
      avatarUrl: otherUser?['photoUrl'] as String?,
      connectedAt: json['connectionDate'] != null 
          ? DateTime.parse(json['connectionDate'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
      type: type,
      sharedInterests: [],
      networkCodeId: json['networkCodeId'] is Map 
          ? (json['networkCodeId'] as Map)['_id'] as String?
          : json['networkCodeId'] as String?,
      codeId: json['codeId'] as String?,
      requestorId: requestorData?['_id'] as String? ?? requestorData?['id'] as String?,
      ownerId: ownerData?['_id'] as String? ?? ownerData?['id'] as String?,
      status: status,
      autoConnected: json['autoConnected'] as bool? ?? false,
    );
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
