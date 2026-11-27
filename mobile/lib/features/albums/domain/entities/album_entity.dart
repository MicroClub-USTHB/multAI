class AlbumEntity {
  final String name;
  final int photoCount;
  final DateTime createdAt;
  final String? coverPhotoPath;

  const AlbumEntity({
    required this.name,
    required this.photoCount,
    required this.createdAt,
    this.coverPhotoPath,
  });

  AlbumEntity copyWith({
    String? name,
    int? photoCount,
    DateTime? createdAt,
    String? coverPhotoPath,
  }) {
    return AlbumEntity(
      name: name ?? this.name,
      photoCount: photoCount ?? this.photoCount,
      createdAt: createdAt ?? this.createdAt,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'photoCount': photoCount,
      'createdAt': createdAt.toIso8601String(),
      'coverPhotoPath': coverPhotoPath,
    };
  }

  factory AlbumEntity.fromJson(Map<String, dynamic> json) {
    return AlbumEntity(
      name: json['name'] as String,
      photoCount: json['photoCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      coverPhotoPath: json['coverPhotoPath'] as String?,
    );
  }
}
