import 'package:dartz/dartz.dart';
import '../../domain/entities/account_entity.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/account_remote_datasource.dart';
import '../datasources/account_local_datasource.dart';
import '../../../../core/errors/failure.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/network_info.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final AccountLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AccountRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, AccountEntity>> getAccountData() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAccount = await remoteDataSource.fetchAccountData();
        await localDataSource.cacheAccountData(remoteAccount);
        return Right(remoteAccount);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      final cachedAccount = await localDataSource.getCachedAccountData();
      if (cachedAccount != null) {
        return Right(cachedAccount);
      }
      return const Left(
        NetworkFailure(message: 'No internet and no cached data.'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Here you can implement actual logout logic (API call + clearing token)
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
