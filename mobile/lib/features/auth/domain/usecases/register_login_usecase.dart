import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import 'dart:async';

class PlaceholderUsecase extends UseCase<void, String> {
  PlaceholderUsecase();

  @override
  FutureOr<Either<Failure, void>> call(String params) async {
    throw UnimplementedError();
  }
}
