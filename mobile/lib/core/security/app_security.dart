import 'package:local_auth/local_auth.dart';

import 'secure_logger.dart';

abstract class IBiometricAuth {
  Future<bool> isBiometricAvailable();
  Future<bool> authenticateWithBiometrics({String reason});
}

class AppSecurity implements IBiometricAuth {
  final LocalAuthentication _localAuth;

  AppSecurity({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (e) {
      SecureLogger.error('AppSecurity', 'Biometric availability check failed', e);
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics({
    String reason = 'Authenticate to access the app',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      SecureLogger.error('AppSecurity', 'Biometric authentication failed', e);
      return false;
    }
  }
}
