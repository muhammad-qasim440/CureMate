import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checkInternetConnectionProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  List<ConnectivityResult> results = await connectivity.checkConnectivity();
  yield _isConnected(results);

  await for (var newResults in connectivity.onConnectivityChanged) {
    yield _isConnected(newResults);
  }
});

bool _isConnected(List<ConnectivityResult> results) {
  return results.isNotEmpty && results[0] != ConnectivityResult.none;
}
final lastConnectionStatusProvider = StateProvider<bool?>((ref) => null);
