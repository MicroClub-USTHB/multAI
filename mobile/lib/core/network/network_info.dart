import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;
  final InternetConnection connectionChecker;

  NetworkInfoImpl({
    required this.connectivity,
    required this.connectionChecker,
  });

  @override
  Future<bool> get isConnected async {
    // Fast, local check first: if the platform reports no active network
    // interface there is no point probing the internet.
    try {
      final results = await connectivity.checkConnectivity();
      if (results.length == 1 && results.contains(ConnectivityResult.none)) {
        return false;
      }
    } catch (_) {
      // Could not determine connectivity — don't block the request.
      return true;
    }

    // Reachability probe against external hosts. This is best-effort: a slow
    // or failed probe (common on cold start / slow emulators) must NOT be
    // treated as "offline" while the platform reports an active network, or
    // otherwise-reachable backends become unreachable. Let the actual request
    // surface a genuine network failure instead.
    try {
      return await connectionChecker.hasInternetAccess.timeout(
        const Duration(seconds: 5),
      );
    } catch (_) {
      return true;
    }
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map((results) {
      if (results.length == 1 && results.contains(ConnectivityResult.none)) {
        return false;
      }
      return true;
    });
  }
}
