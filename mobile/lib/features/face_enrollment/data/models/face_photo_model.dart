import '../../domain/entities/face_photo_entity.dart';
 
class FacePhotoModel extends FacePhotoEntity {
  const FacePhotoModel({
    required super.type,
    required super.filePath,
  });
 
  String get fieldName {
    switch (type) {
      case FacePhotoType.frontal:
        return 'frontal_photo';
      case FacePhotoType.leftProfile:
        return 'left_profile_photo';
      case FacePhotoType.rightProfile:
        return 'right_profile_photo';
    }
  }
}
 