import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  void onNetworkAvailable(Future<void> Function() callback) {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        callback();
      }
    });
  }

  Future<void> dispose() async => _subscription?.cancel();
}
