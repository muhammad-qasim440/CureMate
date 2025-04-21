import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheUtils {
  static Future<void> clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      print('Cache cleared successfully.');
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }
}