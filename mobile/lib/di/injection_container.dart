import 'package:get_it/get_it.dart';
import 'package:multai_mobile/core/security/session_manager.dart';
import 'package:multai_mobile/features/gallery/domain/repositories/photo_repository.dart';
import 'package:multai_mobile/features/gallery/domain/usecases/get_event_photos_usecase.dart';
import 'package:multai_mobile/features/gallery/domain/usecases/get_my_photos_usecase.dart';
import 'package:multai_mobile/features/splash/domain/is_user_loged_in.dart';
import 'package:multai_mobile/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/network/network_info.dart';
import '../core/network/api_client.dart';
import '../core/network/connectivity_service.dart';
import '../core/network/dio_client.dart';
import '../core/storage/app_local_storage.dart';
import '../core/errors/failure_handler.dart';

// Onboarding
import '../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../features/onboarding/domain/usecases/get_onboarding_seen.dart';
import '../features/onboarding/domain/usecases/save_onboarding_seen.dart';
import '../features/onboarding/presentation/bloc/onboarding_bloc.dart';

// Auth
import '../features/auth/data/datasource/remote_data.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/verify_register_usecase.dart';
import '../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/refresh_token_usecase.dart';
import '../features/auth/domain/usecases/get_me_usecase.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';

// Face Enrollment
import '../features/face_enrollment/data/datasources/face_enrollment_local_datasource.dart';
import '../features/face_enrollment/data/datasources/face_enrollment_remote_datasource.dart';
import '../features/face_enrollment/data/repositories/face_enrollment_repository_impl.dart';
import '../features/face_enrollment/domain/repositories/face_enrollment_repository.dart';
import '../features/face_enrollment/domain/usecases/check_enrollment_done_usecase.dart';
import '../features/face_enrollment/domain/usecases/save_enrollment_done_usecase.dart';
import '../features/face_enrollment/domain/usecases/upload_face_photos_usecase.dart';
import '../features/face_enrollment/presentation/bloc/face_enrollment_bloc.dart';

// ── Account ──────────────────────────────────────────────────────────────────
import '../features/account/data/datasources/account_local_datasource.dart';
import '../features/account/data/datasources/account_remote_datasource.dart';
import '../features/account/data/repositories/account_repository_impl.dart';
import '../features/account/domain/repositories/account_repository.dart';
import '../features/account/domain/usecases/get_account_data_usecase.dart';
import '../features/account/presentation/bloc/account_bloc.dart';
//  ── Notifications ───────────────────────────────────────────────────────────
import '../features/notifications/data/datasources/notifications_local_datasource.dart';
import '../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../features/notifications/domain/repositories/notifications_repository.dart';
import '../features/notifications/domain/usecases/get_notifications_usecase.dart';
import '../features/notifications/domain/usecases/mark_as_read_usecase.dart';
import '../features/notifications/domain/usecases/register_device_token_usecase.dart';
import '../features/notifications/domain/usecases/register_push_token_usecase.dart';
import '../features/notifications/domain/usecases/revoke_device_token_usecase.dart';
import '../features/notifications/domain/usecases/revoke_push_token_usecase.dart';
import '../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../features/notifications/services/push_notification_service.dart';
import '../features/notifications/services/notification_navigation_service.dart';
// Photo Approval ─────────────────────────────────────────────
import '../features/photo_approval/presentation/bloc/photo_approval_bloc.dart';
import '../features/photo_approval/data/datasources/photo_approval_remote_datasource.dart';
import '../features/photo_approval/data/repositories/photo_approval_repository_impl.dart';
import '../features/photo_approval/domain/repositories/photo_approval_repository.dart';
import '../features/photo_approval/domain/usecases/decide_photo_approval_usecase.dart';
import '../features/photo_approval/domain/usecases/get_approvals_usecase.dart';

// Events
import '../features/events/data/datasources/events_local_datasource.dart';
import '../features/events/data/datasources/events_remote_datasource.dart';
import '../features/events/data/repositories/events_repository_impl.dart';
import '../features/events/domain/repositories/event_repository.dart';
import '../features/events/domain/usecases/get_events_usecase.dart';
import '../features/events/presentation/bloc/events_bloc.dart';
// gallery
import '../features/gallery/presentation/bloc/gallery_bloc.dart';
import '../features/gallery/data/cache/photo_cache_service.dart';
import '../features/gallery/data/datasources/photo_local_datasource.dart';
import '../features/gallery/data/datasources/photo_remote_datasource.dart';
import '../features/gallery/data/repositories/photo_repository_impl.dart';
import '../features/gallery/domain/usecases/get_photo_image_usecase.dart';

final sl = GetIt.instance;

void registerSessionManager(SessionManager manager) {
  sl.registerLazySingleton<SessionManager>(() => manager);
}

Future<void> init() async {
  await sl.reset();

  // ── External ───────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<AppLocalStorage>(
    () => AppLocalStorage(prefs: sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  // ── Core ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectivity: sl<Connectivity>(),
      connectionChecker: sl<InternetConnection>(),
    ),
  );

  sl.registerLazySingleton(() => ApiClient(
    networkInfo: sl<NetworkInfo>(),
    localStorage: sl<AppLocalStorage>(),
    onUnauthorized: () => sl<AuthBloc>().add(LogoutRequested()),
  ));

  sl.registerLazySingleton<DioClient>(() => DioClient());

  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityService(
      connectivity: sl<Connectivity>(),
      connectionChecker: sl<InternetConnection>(),
    ),
  );

  sl.registerLazySingleton<FailureHandler>(
    () => FailureHandler(),
  );

  // ── Onboarding ─────────────────────────────────────────────────────────────
  sl.registerFactory<SplashBloc>(
    () => SplashBloc(
      getOnboardingSeen: sl<GetOnboardingSeen>(),
      isUserLoggedIn: sl<IsUserLoggedIn>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // ── Onboarding ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl<AppLocalStorage>()),
  );
  sl.registerLazySingleton<GetOnboardingSeen>(
    () => GetOnboardingSeen(sl<OnboardingRepository>()),
  );
  sl.registerLazySingleton<SaveOnboardingSeen>(
    () => SaveOnboardingSeen(sl<OnboardingRepository>()),
  );
  sl.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(
      getSeen: sl<GetOnboardingSeen>(),
      saveSeen: sl<SaveOnboardingSeen>(),
    ),
  );

  // ── Auth Data Source ────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // ── Auth Repository ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      apiClient: sl<ApiClient>(),
      localStorage: sl<AppLocalStorage>(),
    ),
  );

  // ── Auth Use Cases ──────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyRegisterUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResendOtpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => IsUserLoggedIn(sl<AuthRepository>()));

  // ── Auth BLoC ───────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      resendOtpUseCase: sl<ResendOtpUseCase>(),
      verifyRegisterUseCase: sl<VerifyRegisterUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      refreshTokenUseCase: sl<RefreshTokenUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      checkEnrollmentDone: sl<CheckEnrollmentDoneUseCase>(),
      pushNotificationService: sl<PushNotificationService>(),
    ),
  );

  // ── Face Enrollment Data Sources ───────────────────────────────────────────
  sl.registerLazySingleton<FaceEnrollmentLocalDataSource>(
    () =>
        FaceEnrollmentLocalDataSourceImpl(localStorage: sl<AppLocalStorage>()),
  );
  sl.registerLazySingleton<FaceEnrollmentRemoteDataSource>(
    () => FaceEnrollmentRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // ── Face Enrollment Repository ─────────────────────────────────────────────
  sl.registerLazySingleton<FaceEnrollmentRepository>(
    () => FaceEnrollmentRepositoryImpl(
      remoteDataSource: sl<FaceEnrollmentRemoteDataSource>(),
      localDataSource: sl<FaceEnrollmentLocalDataSource>(),
    ),
  );

  // ── Face Enrollment Use Cases ──────────────────────────────────────────────
  sl.registerLazySingleton(
    () => UploadFacePhotosUseCase(sl<FaceEnrollmentRepository>()),
  );
  sl.registerLazySingleton(
    () => CheckEnrollmentDoneUseCase(sl<FaceEnrollmentRepository>()),
  );
  sl.registerLazySingleton(
    () => SaveEnrollmentDoneUseCase(sl<FaceEnrollmentRepository>()),
  );

  // ── Face Enrollment BLoC ───────────────────────────────────────────────────
  sl.registerFactory<FaceEnrollmentBloc>(
    () => FaceEnrollmentBloc(
      uploadFacePhotos: sl<UploadFacePhotosUseCase>(),
      saveEnrollmentDone: sl<SaveEnrollmentDoneUseCase>(),
      failureHandler: sl<FailureHandler>(),
    ),
  );

  // ── Account DI ───────────────────────────────────────────────────────────
  sl.registerLazySingleton<AccountLocalDataSource>(
    () => AccountLocalDataSourceImpl(localStorage: sl<AppLocalStorage>()),
  );

  sl.registerLazySingleton<AccountRemoteDataSource>(
    () => AccountRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(
      remoteDataSource: sl<AccountRemoteDataSource>(), // required
      localDataSource: sl<AccountLocalDataSource>(),
    ),
  );

  // ── Account Use Cases ─────────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => GetAccountDataUseCase(sl<AccountRepository>()),
  );

  // ── Account BLoC ─────────────────────────────────────────────────────────
  sl.registerFactory<AccountBloc>(
    () => AccountBloc(
      getAccountData: sl<GetAccountDataUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      pushNotificationService: sl<PushNotificationService>(),
    ),
  );

  // ── Events Data Sources ────────────────────────────────────────────────────
  sl.registerLazySingleton<EventsRemoteDataSource>(
    () => EventsRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<EventsLocalDataSource>(
    () => EventsLocalDataSourceImpl(localStorage: sl<AppLocalStorage>()),
  );

  // ── Events Repository ───────────────────────────────────────────────────────
  sl.registerLazySingleton<EventRepository>(
    () => EventsRepositoryImpl(
      remoteDataSource: sl<EventsRemoteDataSource>(),
      localDataSource: sl<EventsLocalDataSource>(),
    ),
  );

  // ── Events Use Cases ────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetUserEventsUseCase(sl<EventRepository>()));
  sl.registerLazySingleton(() => JoinEventUseCase(sl<EventRepository>()));

  // ── Events BLoC ─────────────────────────────────────────────────────────────
  sl.registerFactory<EventsBloc>(
    () => EventsBloc(
      getUserEventsUseCase: sl<GetUserEventsUseCase>(),
      joinEventUseCase: sl<JoinEventUseCase>(),
      connectivityService: sl<ConnectivityService>(),
    ),
  );
  // Notification Data Sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<NotificationsLocalDataSource>(
    () => NotificationsLocalDataSource(localStorage: sl<AppLocalStorage>()),
  );

  // Notification Repository
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl<NotificationRemoteDataSource>(),
      localDataSource: sl<NotificationsLocalDataSource>(),
    ),
  );

  // Notification Use Cases
  sl.registerLazySingleton(
    () => GetNotificationsUsecase(sl<NotificationsRepository>()),
  );
  sl.registerLazySingleton(
    () => MarkAsReadUsecase(sl<NotificationsRepository>()),
  );

  sl.registerLazySingleton(
    () => RegisterPushTokenUseCase(sl<NotificationsRepository>()),
  );
  sl.registerLazySingleton(
    () => RevokePushTokenUsecase(sl<NotificationsRepository>()),
  );

  // Notification Navigation Service
  sl.registerLazySingleton(() => NotificationNavigationService());

  // Push Notification Service
  sl.registerLazySingleton(
    () => PushNotificationService(
      registerToken: sl<RegisterPushTokenUseCase>(),
      revokeToken: sl<RevokePushTokenUsecase>(),
      navigationService: sl<NotificationNavigationService>(),
    ),
  );

  // Device Token Use Cases
  sl.registerLazySingleton(
    () => RegisterDeviceTokenUseCase(sl<PushNotificationService>()),
  );
  sl.registerLazySingleton(
    () => RevokeDeviceTokenUseCase(sl<PushNotificationService>()),
  );

  // Notification BLoC
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(
      getNotifications: sl<GetNotificationsUsecase>(),
      markAsRead: sl<MarkAsReadUsecase>(),
      registerPushToken: sl<RegisterPushTokenUseCase>(),
      connectivityService: sl<ConnectivityService>(),
      pushNotificationService: sl<PushNotificationService>(),
    ),
  );

  // Photo Approval Remote DataSource
  sl.registerLazySingleton<PhotoApprovalRemoteDataSource>(
    () => PhotoApprovalRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Photo Approval Repository
  sl.registerLazySingleton<PhotoApprovalRepository>(
    () => PhotoApprovalRepositoryImpl(
      remoteDataSource: sl<PhotoApprovalRemoteDataSource>(),
    ),
  );

  // Photo Approval Use Cases
  sl.registerLazySingleton(
    () => GetApprovalsUsecase(repository: sl<PhotoApprovalRepository>()),
  );
  sl.registerLazySingleton(
    () => DecidePhotoApprovalUseCase(sl<PhotoApprovalRepository>()),
  );

  // Photo Approval BLoC
  sl.registerFactory<PhotoApprovalBloc>(
    () => PhotoApprovalBloc(
      getApprovals: sl<GetApprovalsUsecase>(),
      decideApproval: sl<DecidePhotoApprovalUseCase>(),
    ),
  );
  // Cache Service
  sl.registerLazySingleton(() => PhotoCacheService());

  // Gallery Remote DataSource
  sl.registerLazySingleton<PhotoRemoteDataSource>(
    () => PhotoRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<PhotoLocalDataSource>(
    () => PhotoLocalDataSource(localStorage: sl<AppLocalStorage>()),
  );

  // Gallery Repository
  sl.registerLazySingleton<PhotoRepository>(
    () => PhotoRepositoryImpl(
      remoteDataSource: sl<PhotoRemoteDataSource>(),
      cacheService: sl<PhotoCacheService>(),
      localDataSource: sl<PhotoLocalDataSource>(),
    ),
  );

  // Gallery Use Cases
  sl.registerLazySingleton(() => GetMyPhotosUseCase(sl<PhotoRepository>()));
  sl.registerLazySingleton(() => GetEventPhotosUseCase(sl<PhotoRepository>()));
  sl.registerLazySingleton(() => GetPhotoImageUseCase(sl<PhotoRepository>()));

  // Gallery BLoC
  sl.registerFactory<GalleryBloc>(
    () => GalleryBloc(
      getMyPhotos: sl<GetMyPhotosUseCase>(),
      getEventPhotos: sl<GetEventPhotosUseCase>(),
      getPhotoImage: sl<GetPhotoImageUseCase>(),
      connectivityService: sl<ConnectivityService>(),
    ),
  );

  // ── Initialize ConnectivityService ─────────────────────────────────────────
  await sl<ConnectivityService>().init();
}
