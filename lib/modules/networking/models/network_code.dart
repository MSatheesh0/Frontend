class NetworkCode {
  final String id;
  final String name;
  final String codeId;
  final String description;
  final List<String> keywords;
  final bool autoConnect;

  NetworkCode({
    required this.id,
    required this.name,
    required this.codeId,
    required this.description,
    required this.keywords,
    this.autoConnect = false,
  });

  factory NetworkCode.fromJson(Map<String, dynamic> json) {
    return NetworkCode(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      codeId: json['codeId'] ?? json['code'] ?? '', // Backend sends codeId or code
      description: json['description'] ?? '',
      keywords: (json['keywords'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? 
                (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      autoConnect: json['autoConnect'] ?? false,
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
    };
  }

  NetworkCode copyWith({
    String? id,
    String? name,
    String? codeId,
    String? description,
    List<String>? keywords,
    bool? autoConnect,
  }) {
    return NetworkCode(
      id: id ?? this.id,
      name: name ?? this.name,
      codeId: codeId ?? this.codeId,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      autoConnect: autoConnect ?? this.autoConnect,
    );
  }
}
