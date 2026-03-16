import 'package:equatable/equatable.dart';
 
abstract class Failure extends Equatable {
  const Failure([this.properties = const <dynamic>[]]);
 
  final List<dynamic> properties;
 
  @override
  List get props => properties;
}
 
class ServerFailure extends Failure {
  final String message;
  const ServerFailure({required this.message}) : super(const []);
 
  @override
  List<Object?> get props => [message];
}
 
class NetworkFailure extends Failure {
  final String message;
  const NetworkFailure({required this.message}) : super(const []);
 
  @override
  List<Object?> get props => [message];
}
 
class UnauthorizedFailure extends Failure {
  final String message;
  const UnauthorizedFailure({required this.message}) : super(const []);
 
  @override
  List<Object?> get props => [message];
}
 
class CacheFailure extends Failure {
  const CacheFailure() : super(const []);
}
 