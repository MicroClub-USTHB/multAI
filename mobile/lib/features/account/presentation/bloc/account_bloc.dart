import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure_handler.dart';
import '../../../../features/notifications/services/push_notification_service.dart';
import '../../../../features/auth/utils/device_utils.dart';
import '../../domain/usecases/get_account_data_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../../core/usecase/usecase.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccountDataUseCase _getAccountData;
  final LogoutUseCase _logoutUseCase;
  final PushNotificationService _pushNotificationService;
  final FailureHandler _failureHandler;

  AccountBloc({
    required GetAccountDataUseCase getAccountData,
    required LogoutUseCase logoutUseCase,
    required PushNotificationService pushNotificationService,
    FailureHandler? failureHandler,
  }) : _getAccountData = getAccountData,
       _logoutUseCase = logoutUseCase,
       _pushNotificationService = pushNotificationService,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(AccountInitial()) {
    on<LoadAccountData>(_onLoadAccountData);
    on<LogoutRequested>(_onLogoutRequested);
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

    result.fold((failure) {
      _failureHandler.logFailure(failure, 'AccountBloc');
      emit(
        AccountError(message: _failureHandler.getUserFriendlyMessage(failure)),
      );
    }, (_) => emit(AccountLoggedOut()));
  }
}
