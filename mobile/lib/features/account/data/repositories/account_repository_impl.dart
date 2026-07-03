import 'package:dartz/dartz.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';
import '../datasources/account_local_datasource.dart';
import '../models/account_model.dart';
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
      final cachedAccount = await localDataSource.getCachedAccountData();
      final merged = AccountModel(
        name: remoteAccount.name,
        email: remoteAccount.email,
        avatarUrl: remoteAccount.avatarUrl ?? cachedAccount?.avatarUrl,
      );
      await localDataSource.cacheAccountData(merged);
      return Right(merged);
    } on Failure catch (f) {
      final cachedAccount = await localDataSource.getCachedAccountData();
      if (cachedAccount != null) {
        return Right(cachedAccount);
      }
      return Left(f);
    } catch (e) {
      return Left(const UnknownFailure('Failed to load account data'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String filePath) async {
    try {
      final avatarUrl = await remoteDataSource.uploadAvatar(filePath);
      final cached = await localDataSource.getCachedAccountData();
      if (cached != null) {
        final updated = AccountModel(
          name: cached.name,
          email: cached.email,
          avatarUrl: avatarUrl,
        );
        await localDataSource.cacheAccountData(updated);
      }
      return Right(avatarUrl);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(const UnknownFailure('Failed to upload avatar'));
    }
  }
}
