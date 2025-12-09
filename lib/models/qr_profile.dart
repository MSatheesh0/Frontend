class QrProfile {
  final String id;
  final String name;
  final String qrCodeId;
  final String description;
  final List<String> keywords;
  final bool autoConnect;

  QrProfile({
    required this.id,
    required this.name,
    required this.qrCodeId,
    required this.description,
    required this.keywords,
    this.autoConnect = false,
  });

  QrProfile copyWith({
    String? id,
    String? name,
    String? qrCodeId,
    String? description,
    List<String>? keywords,
    bool? autoConnect,
  }) {
    return QrProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      qrCodeId: qrCodeId ?? this.qrCodeId,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
      autoConnect: autoConnect ?? this.autoConnect,
    );
  }
}
