import 'package:dartz/dartz.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';
import '../datasources/account_local_datasource.dart';
import '../../../../core/errors/failure.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final AccountLocalDataSource localDataSource;

  AccountRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AccountEntity>> getAccountData() async {
    try {
      final remoteAccount = await remoteDataSource.fetchAccountData();
      await localDataSource.cacheAccountData(remoteAccount);
      return Right(remoteAccount);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
