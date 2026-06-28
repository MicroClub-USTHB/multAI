import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure_handler.dart';
import '../../../../core/errors/failure.dart';
import '../../../../features/notifications/services/push_notification_service.dart';
import '../../../../features/auth/utils/device_utils.dart';
import '../../domain/usecases/get_account_data_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../gallery/data/cache/photo_cache_service.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccountDataUseCase _getAccountData;
  final LogoutUseCase _logoutUseCase;
  final PushNotificationService _pushNotificationService;
  final PhotoCacheService _photoCacheService;
  final FailureHandler _failureHandler;

  AccountBloc({
    required GetAccountDataUseCase getAccountData,
    required LogoutUseCase logoutUseCase,
    required PushNotificationService pushNotificationService,
    required PhotoCacheService photoCacheService,
    FailureHandler? failureHandler,
  }) : _getAccountData = getAccountData,
       _logoutUseCase = logoutUseCase,
       _pushNotificationService = pushNotificationService,
       _photoCacheService = photoCacheService,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(AccountInitial()) {
    on<LoadAccountData>(_onLoadAccountData);
    on<LogoutRequested>(_onLogoutRequested);
    on<ClearImageCacheRequested>(_onClearImageCache);
  }

  Future<void> _onLoadAccountData(
    LoadAccountData event,
    Emitter<AccountState> emit,
  ) async {
    if (state is AccountLoaded || state is AccountLoading) return;
    emit(AccountLoading());

    final result = await _getAccountData(NoParams());

    result.fold(
      (failure) {
        _failureHandler.logFailure(failure, 'AccountBloc');
        emit(
          AccountError(
            message: _failureHandler.getUserFriendlyMessage(failure),
          ),
        );
      },
      (account) => emit(
        AccountLoaded(
          name: account.name,
          email: account.email,
          avatarUrl: account.avatarUrl,
        ),
      ),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());

    await _pushNotificationService.revokeToken();
    final result = await _logoutUseCase(NoParams());
    await DeviceUtils.clearDeviceId();
    await _photoCacheService.clearCache();

    result.fold((failure) {
      _failureHandler.logFailure(failure, 'AccountBloc');
      emit(
        AccountError(message: _failureHandler.getUserFriendlyMessage(failure)),
      );
    }, (_) => emit(AccountLoggedOut()));
  }

  Future<void> _onClearImageCache(
    ClearImageCacheRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountCacheClearing());
    try {
      final before = await _photoCacheService.getStats();
      await _photoCacheService.clearCache();
      emit(AccountCacheCleared(
        storageFreed: before.formattedSize,
        filesRemoved: before.fileCount,
      ));
    } catch (e) {
      _failureHandler.logFailure(
        UnknownFailure('Failed to clear cache: $e'),
        'AccountBloc',
      );
      emit(AccountError(
        message: _failureHandler.getUserFriendlyMessage(
          const UnknownFailure('Failed to clear cache'),
        ),
      ));
    }
  }
}
