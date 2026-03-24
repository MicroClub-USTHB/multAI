// photo type
enum FacePhotoType {
  frontal, //
  leftProfile,
  rightProfile,
  extra1, // Optional
  extra2, // Optional
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
      case FacePhotoType.extra1:
        return 'Optional1';
      case FacePhotoType.extra2:
        return 'Optional2';
    }
  }

  bool get isPrimary => this == FacePhotoType.frontal;
}

// entity
class FacePhotoEntity {
  final FacePhotoType type;
  final String filePath;

  const FacePhotoEntity({required this.type, required this.filePath});
}
