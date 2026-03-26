import '../entities/account_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

abstract class AccountRepository {
  /// Fetch account data
  Future<Either<Failure, AccountEntity>> getAccountData();

  /// Logout the user
  Future<Either<Failure, void>> logout();
}
