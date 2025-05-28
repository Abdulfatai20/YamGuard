import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/services/expiry_service.dart';

final expiryCleanupProvider = Provider<Timer>((ref) {
  print('🚀 Initializing expiry cleanup service...');
  
  // Run cleanup every hour (you can adjust this interval)
  final timer = Timer.periodic(Duration(hours: 1), (timer) {
    print('⏰ Running scheduled expiry cleanup...');
    ExpiryService.moveExpiredItems();
  });
  
  // Run cleanup immediately when app starts
  ExpiryService.moveExpiredItems();
  
  // Clean up timer when provider is disposed
  ref.onDispose(() {
    print('🛑 Disposing expiry cleanup timer');
    timer.cancel();
  });
  
  return timer;
});