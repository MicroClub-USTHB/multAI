import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/auth_entity.dart';
import '../entities/user_entity.dart';
 
abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login(LoginParams params);
  Future<Either<Failure, AuthEntity>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, MeEntity>> getMe();
}
 
class LoginParams {
  final String email;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceId;
  final String fingerprint;
 
  const LoginParams({
    required this.email,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceId,
    required this.fingerprint,
  });
}
 

 