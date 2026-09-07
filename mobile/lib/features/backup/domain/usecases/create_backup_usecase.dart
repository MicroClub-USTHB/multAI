import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/backup_repository.dart';

class CreateBackupUseCase extends UseCase<File, NoParams> {
  final BackupRepository _repository;

  CreateBackupUseCase(this._repository);

  @override
  Future<Either<Failure, File>> call(NoParams params) async {
    final pathsResult = await _repository.getCachedPhotoPaths();

    return pathsResult.fold(
      (failure) => Left(failure),
      (paths) async {
        if (paths.isEmpty) {
          return const Left(CacheFailure('No cached photos to backup'));
        }
        return _repository.createBackupZip(paths);
      },
    );
  }
}
