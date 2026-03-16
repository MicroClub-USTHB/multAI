// import 'package:get_it/get_it.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'dart:async';

// import '../core/network/network_info.dart';
// import '../core/network/api_client.dart';

// // Onboarding
// import '../features/onboarding/data/repositories/onboarding_repository_impl.dart';
// import '../features/onboarding/domain/repositories/onboarding_repository.dart';
// import '../features/onboarding/domain/usecases/get_onboarding_seen.dart';
// import '../features/onboarding/domain/usecases/save_onboarding_seen.dart';
// import '../features/onboarding/presentation/bloc/onboarding_bloc.dart';

// // Auth
// import '../features/auth/data/datasource/remote_data.dart';
// import '../features/auth/data/repositories/auth_repository_impl.dart';
// import '../features/auth/domain/repositories/auth_repository.dart';
// import '../features/auth/domain/usecases/login_usecase.dart';
// // import '../features/auth/domain/usecases/logout_usecase.dart';
// // import '../features/auth/domain/usecases/refresh_token_usecase.dart';
// // import '../features/auth/domain/usecases/get_me_usecase.dart';
// // import '../features/auth/presentation/blocs/auth_bloc.dart';

// // final sl = GetIt.instance;

// // FutureOr<void> init() async {
// //   await sl.reset();

// //   // ── External ───────────────────────────────────────────────────────────────
// //   final sharedPreferences = await SharedPreferences.getInstance();
// //   sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
// //   sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
// //   sl.registerLazySingleton<Connectivity>(() => Connectivity());
// //   sl.registerLazySingleton<http.Client>(() => http.Client());

// //   // ── Core ───────────────────────────────────────────────────────────────────
// //   sl.registerLazySingleton<NetworkInfo>(
// //     () => NetworkInfoImpl(
// //       connectivity: sl<Connectivity>(),
// //       connectionChecker: sl<InternetConnection>(),
// //     ),
// //   );

// //   sl.registerLazySingleton(
// //     () => ApiClient(
// //       client: sl<http.Client>(),
// //       networkInfo: sl<NetworkInfo>(),
// //     ),
// //   );

// //   // ── Onboarding ─────────────────────────────────────────────────────────────
// //   sl.registerLazySingleton<OnboardingRepository>(
// //     () => OnboardingRepositoryImpl(sl<SharedPreferences>()),
// //   );
// //   sl.registerLazySingleton<GetOnboardingSeen>(
// //     () => GetOnboardingSeen(sl<OnboardingRepository>()),
// //   );
// //   sl.registerLazySingleton<SaveOnboardingSeen>(
// //     () => SaveOnboardingSeen(sl<OnboardingRepository>()),
// //   );
// //   sl.registerFactory<OnboardingBloc>(
// //     () => OnboardingBloc(
// //       getSeen: sl<GetOnboardingSeen>(),
// //       saveSeen: sl<SaveOnboardingSeen>(),
// //     ),
// //   );

// //   // ── Auth Data Source ────────────────────────────────────────────────────────
// //   sl.registerLazySingleton<AuthRemoteDataSource>(
// //     () => AuthRemoteDataSourceImpl(
// //       apiClient: sl<ApiClient>(),
// //     ),
// //   );

// //   // ── Auth Repository ─────────────────────────────────────────────────────────
// //   sl.registerLazySingleton<AuthRepository>(
// //     () => AuthRepositoryImpl(
// //       remoteDataSource: sl<AuthRemoteDataSource>(),
// //     ),
// //   );

// //   // ── Auth Use Cases ──────────────────────────────────────────────────────────
// //   sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
// //   sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
// //   sl.registerLazySingleton(() => RefreshTokenUseCase(sl<AuthRepository>()));
// //   sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));

// //   // ── Auth BLoC ───────────────────────────────────────────────────────────────
// //   sl.registerFactory<AuthBloc>(
// //     () => AuthBloc(
// //       loginUseCase:          sl<LoginUseCase>(),
// //       logoutUseCase:         sl<LogoutUseCase>(),
// //       refreshTokenUseCase:   sl<RefreshTokenUseCase>(),
// //       getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
// //     ),
// //   );
// // }

















import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
 
import '../core/network/network_info.dart';
import '../core/network/api_client.dart';
 
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
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/refresh_token_usecase.dart';
import '../features/auth/domain/usecases/get_me_usecase.dart';
import '../features/auth/presentation/blocs/auth_bloc.dart';
 
final sl = GetIt.instance;
 
FutureOr<void> init() async {
  await sl.reset();
 
  // ── External ───────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<http.Client>(() => http.Client());
 
  // ── Core ───────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectivity: sl<Connectivity>(),
      connectionChecker: sl<InternetConnection>(),
    ),
  );
 
  sl.registerLazySingleton(
    () => ApiClient(
      client: sl<http.Client>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );
 
  // ── Onboarding ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl<SharedPreferences>()),
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
    () => AuthRemoteDataSourceImpl(
      apiClient: sl<ApiClient>(),
    ),
  );
 
  // ── Auth Repository ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      apiClient: sl<ApiClient>(),
    ),
  );
 
  // ── Auth Use Cases ──────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
 
  // ── Auth BLoC ───────────────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase:          sl<LoginUseCase>(),
      logoutUseCase:         sl<LogoutUseCase>(),
      refreshTokenUseCase:   sl<RefreshTokenUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );
}
 