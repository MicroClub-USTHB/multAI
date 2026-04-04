import '../entities/account_entity.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

abstract class AccountRepository {

  Future<Either<Failure, AccountEntity>> getAccountData();
}
