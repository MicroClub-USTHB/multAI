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
        return 'Front View';
      case FacePhotoType.leftProfile:
        return 'Turn Left';
      case FacePhotoType.rightProfile:
        return 'Turn Right';
      case FacePhotoType.extra1:
        return 'Tilt Up';
      case FacePhotoType.extra2:
        return 'Tilt Down';
    }
  }

  String get angleInstruction {
    switch (this) {
      case FacePhotoType.frontal:
        return 'Face the camera directly';
      case FacePhotoType.leftProfile:
        return 'Turn head slightly left';
      case FacePhotoType.rightProfile:
        return 'Turn head slightly right';
      case FacePhotoType.extra1:
        return 'Tilt head slightly up';
      case FacePhotoType.extra2:
        return 'Tilt head slightly down';
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

  /// Yaw rotation in radians (positive = turn left).
  double get yaw {
    switch (this) {
      case FacePhotoType.frontal:
        return 0.0;
      case FacePhotoType.leftProfile:
        return 0.55;
      case FacePhotoType.rightProfile:
        return -0.55;
      case FacePhotoType.extra1:
        return 0.15;
      case FacePhotoType.extra2:
        return -0.15;
    }
  }

  /// Pitch rotation in radians (positive = tilt up).
  double get pitch {
    switch (this) {
      case FacePhotoType.frontal:
        return 0.0;
      case FacePhotoType.leftProfile:
        return 0.0;
      case FacePhotoType.rightProfile:
        return 0.0;
      case FacePhotoType.extra1:
        return 0.35;
      case FacePhotoType.extra2:
        return -0.35;
    }
  }
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
