class RadioStation {
  final int? id;
  final String name;
  final String streamUrl;
  final String imageUrl;
  final bool isFavorite;
  final int position;

  RadioStation({
    this.id,
    required this.name,
    required this.streamUrl,
    this.imageUrl = '',
    this.isFavorite = false,
    this.position = 0,
  });

  RadioStation copyWith({
    int? id,
    String? name,
    String? streamUrl,
    String? imageUrl,
    bool? isFavorite,
    int? position,
  }) {
    return RadioStation(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      position: position ?? this.position,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'stream_url': streamUrl,
      'image_url': imageUrl,
      'is_favorite': isFavorite ? 1 : 0,
      'position': position,
    };
  }

  factory RadioStation.fromMap(Map<String, dynamic> map) {
    return RadioStation(
      id: map['id'] as int?,
      name: map['name'] as String,
      streamUrl: map['stream_url'] as String,
      imageUrl: map['image_url'] as String? ?? '',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      position: map['position'] as int? ?? 0,
    );
  }
}

