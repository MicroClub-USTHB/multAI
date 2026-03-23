// photo type
enum FacePhotoType {
  frontal,    // PRIMARY
  leftProfile,
  rightProfile,
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


