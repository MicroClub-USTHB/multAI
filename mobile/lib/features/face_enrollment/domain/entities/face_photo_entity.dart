enum FacePhotoType {
  frontal,
  leftProfile,
  rightProfile,
  extra1,
  extra2;

  static List<FacePhotoType> get required => [
    frontal,
    leftProfile,
    rightProfile,
  ];

  static List<FacePhotoType> get optional => [extra1, extra2];
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
        return 'Extra View 1';
      case FacePhotoType.extra2:
        return 'Extra View 2';
    }
  }

  String get shortLabel {
    switch (this) {
      case FacePhotoType.frontal:
        return 'Front';
      case FacePhotoType.leftProfile:
        return 'Left';
      case FacePhotoType.rightProfile:
        return 'Right';
      case FacePhotoType.extra1:
        return 'Extra 1';
      case FacePhotoType.extra2:
        return 'Extra 2';
    }
  }

  bool get isPrimary => this == FacePhotoType.frontal;

  bool get isRequired =>
      this == FacePhotoType.frontal ||
      this == FacePhotoType.leftProfile ||
      this == FacePhotoType.rightProfile;
}

extension FacePhotoMapX on Map<FacePhotoType, String> {
  bool get hasRequiredPhotos =>
      FacePhotoType.required.every((type) => this[type] != null);

  int get requiredCount => entries.where((e) => e.key.isRequired).length;

  int get optionalCount => entries.where((e) => !e.key.isRequired).length;
}

class FacePhotoEntity {
  final FacePhotoType type;
  final String filePath;

  const FacePhotoEntity({required this.type, required this.filePath});
}
