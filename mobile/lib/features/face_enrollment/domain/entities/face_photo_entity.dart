// photo type
enum FacePhotoType {
  frontal,    // PRIMARY
  leftProfile,
  rightProfile,
}

extension FacePhotoTypeX on FacePhotoType {
  String get label {
    switch (this) {
      case FacePhotoType.frontal:
        return 'Frontal View';
      case FacePhotoType.leftProfile:
        return 'Left Profile';
      case FacePhotoType.rightProfile:
        return 'Right Profile';
    }
  }
 
  bool get isPrimary => this == FacePhotoType.frontal;
}

// entity
class FacePhotoEntity {
  final FacePhotoType type;
  final String filePath;

  const FacePhotoEntity({
    required this.type,
    required this.filePath,
  });
}


