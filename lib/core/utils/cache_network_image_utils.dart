import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'debug_print.dart';

class CacheUtils {
  static Future<void> clearCache() async {
    try {
      await DefaultCacheManager().emptyCache();
      logDebug('Cache cleared successfully.');
    } catch (e) {
      logDebug('Failed to clear cache: $e');
    }
  }
}