class NetworkCode {
  final String id;
  final String name;
  final String codeId;
  final String? description;
  final List<String> keywords;
  final bool autoConnect;
  final bool isActive;
  final int maxConnections;
  final int currentConnections;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  NetworkCode({
    required this.id,
    required this.name,
    required this.codeId,
    this.description,
    required this.keywords,
    this.autoConnect = false,
    this.isActive = true,
    this.maxConnections = 100,
    this.currentConnections = 0,
    this.createdAt,
    this.expiresAt,
  });

  /// Check if this network code has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if this code is currently valid (active and not expired)
  bool get isValid => isActive && !isExpired;

  NetworkCode copyWith({
    String? id,
    String? name,
    String? codeId,
    String? description,
    List<String>? keywords,
    bool? autoConnect,
    bool? isActive,
    int? maxConnections,
    int? currentConnections,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return NetworkCode(
      id: id ?? this.id,
      name: name ?? this.name,
      codeId: codeId ?? this.codeId,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      autoConnect: autoConnect ?? this.autoConnect,
      isActive: isActive ?? this.isActive,
      maxConnections: maxConnections ?? this.maxConnections,
      currentConnections: currentConnections ?? this.currentConnections,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
  factory NetworkCode.fromMap(Map<String, dynamic> map) {
    return NetworkCode(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed',
      codeId: map['code']?.toString() ?? '',
      description: map['description']?.toString(),
      keywords: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      autoConnect: map['autoConnect'] == true,
      isActive: map['isActive'] ?? true,
      maxConnections: (map['maxConnections'] as num?)?.toInt() ?? 100,
      currentConnections: (map['currentConnections'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null,
      expiresAt: map['expiresAt'] != null ? DateTime.tryParse(map['expiresAt'].toString()) : null,
    );
  }

  factory NetworkCode.fromJson(Map<String, dynamic> json) {
    return NetworkCode(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed',
      codeId: json['codeId']?.toString() ?? json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      keywords: (json['keywords'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? 
                (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      autoConnect: json['autoConnect'] == true,
      isActive: json['isActive'] ?? true,
      maxConnections: (json['maxConnections'] as num?)?.toInt() ?? 100,
      currentConnections: (json['currentConnections'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'codeId': codeId,
      'description': description,
      'keywords': keywords,
      'autoConnect': autoConnect,
      'isActive': isActive,
      'maxConnections': maxConnections,
      'currentConnections': currentConnections,
      'createdAt': createdAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }
}
