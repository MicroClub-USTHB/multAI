import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:extended_image/extended_image.dart';

import '../../../../core/errors/failure_handler.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/error_presentation.dart';
import '../../../../features/notifications/services/push_notification_service.dart';
import '../../../../features/auth/utils/device_utils.dart';
import '../../domain/usecases/get_account_data_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../gallery/data/cache/photo_cache_service.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccountDataUseCase _getAccountData;
  final UploadAvatarUseCase _uploadAvatar;
  final UpdateProfileUseCase _updateProfile;
  final LogoutUseCase _logoutUseCase;
  final PushNotificationService _pushNotificationService;
  final PhotoCacheService _photoCacheService;
  final FailureHandler _failureHandler;

  AccountBloc({
    required GetAccountDataUseCase getAccountData,
    required UploadAvatarUseCase uploadAvatar,
    required UpdateProfileUseCase updateProfile,
    required LogoutUseCase logoutUseCase,
    required PushNotificationService pushNotificationService,
    required PhotoCacheService photoCacheService,
    FailureHandler? failureHandler,
  }) : _getAccountData = getAccountData,
       _uploadAvatar = uploadAvatar,
       _updateProfile = updateProfile,
       _logoutUseCase = logoutUseCase,
       _pushNotificationService = pushNotificationService,
       _photoCacheService = photoCacheService,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(AccountInitial()) {
    on<LoadAccountData>(_onLoadAccountData);
    on<ResetAccountData>(_onResetAccountData);
    on<LogoutRequested>(_onLogoutRequested);
    on<ClearImageCacheRequested>(_onClearImageCache);
    on<UploadAvatar>(_onUploadAvatar);
    on<UpdateProfileRequested>(_onUpdateProfile);
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
            errorPresentation: _failureHandler.getErrorPresentation(failure),
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

  void _onResetAccountData(ResetAccountData event, Emitter<AccountState> emit) {
    emit(AccountInitial());
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());

    // Best-effort cleanup must not delay the visible sign-out. The push token
    // revoke is started first so it can still use the in-memory access token;
    // the local session is cleared right after, and the photo cache is purged
    // in the background once navigation has been requested.
    unawaited(_revokePushTokenQuietly());
    final result = await _logoutUseCase(NoParams());
    result.fold(
      (failure) => _failureHandler.logFailure(failure, 'AccountBloc'),
      (_) {},
    );
    await DeviceUtils.clearDeviceId();

    if (emit.isDone) return;
    emit(AccountLoggedOut());
    unawaited(_clearPhotoCacheQuietly());
  }

  Future<void> _revokePushTokenQuietly() async {
    try {
      await _pushNotificationService.revokeToken();
    } catch (_) {}
  }

  Future<void> _clearPhotoCacheQuietly() async {
    try {
      await _photoCacheService.clearCache();
    } catch (_) {}
  }

  Future<void> _onClearImageCache(
    ClearImageCacheRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountCacheClearing());
    try {
      final before = await _photoCacheService.getStats();
      await _photoCacheService.clearCache();
      emit(
        AccountCacheCleared(
          storageFreed: before.formattedSize,
          filesRemoved: before.fileCount,
        ),
      );
    } catch (e) {
      _failureHandler.logFailure(
        UnknownFailure('Failed to clear cache: $e'),
        'AccountBloc',
      );
      emit(
        AccountError(
          errorPresentation: _failureHandler.getErrorPresentation(
            const UnknownFailure('Failed to clear cache'),
          ),
        ),
      );
    }
  }

  Future<void> _onUploadAvatar(
    UploadAvatar event,
    Emitter<AccountState> emit,
  ) async {
    final current = state;
    if (current is AccountLoaded) {
      emit(
        AccountAvatarUploading(
          name: current.name,
          email: current.email,
          avatarUrl: current.avatarUrl,
        ),
      );
    }

    final result = await _uploadAvatar(
      UploadAvatarParams(filePath: event.filePath),
    );

    await result.fold(
      (failure) async {
        _failureHandler.logFailure(failure, 'AccountBloc');
        if (current is AccountLoaded) {
          emit(current);
        }
        emit(
          AccountError(
            errorPresentation: _failureHandler.getErrorPresentation(failure),
          ),
        );
      },
      (avatarUrl) async {
        await ExtendedNetworkImageProvider(avatarUrl).evict();
        await clearDiskCachedImage(avatarUrl);
        if (current is AccountLoaded) {
          emit(current.copyWith(avatarUrl: avatarUrl));
        }
      },
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<AccountState> emit,
  ) async {
    final current = state;
    if (current is AccountLoaded) {
      emit(
        AccountProfileUpdating(
          name: current.name,
          email: current.email,
          avatarUrl: current.avatarUrl,
        ),
      );
    }

    final result = await _updateProfile(UpdateProfileParams(name: event.name));

    result.fold(
      (failure) {
        _failureHandler.logFailure(failure, 'AccountBloc');
        if (current is AccountLoaded) {
          emit(current);
        }
        emit(
          AccountError(
            errorPresentation: _failureHandler.getErrorPresentation(failure),
          ),
        );
      },
      (account) {
        if (current is AccountLoaded) {
          emit(current.copyWith(name: account.name));
        }
      },
    );
  }
}
