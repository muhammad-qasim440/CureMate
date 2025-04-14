import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final checkInternetConnectionProvider = FutureProvider<bool>((ref) async {
  final connectivity = Connectivity();
  final results = await connectivity.checkConnectivity();
  return results.any((result) => result != ConnectivityResult.none);

});
