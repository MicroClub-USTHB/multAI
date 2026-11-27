import 'dart:async';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/app_local_storage.dart';
import '../../domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final AppLocalStorage _storage;

  OnboardingRepositoryImpl(this._storage);

  @override
  FutureOr<bool> getSeenOnboarding() async {
    return _storage.getBool(StorageKeys.seenOnboarding) ?? false;
  }

  @override
  FutureOr<void> setSeenOnboarding(bool seen) async {
    await _storage.setBool(StorageKeys.seenOnboarding, seen);
  }
}
