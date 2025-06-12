import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/providers/notification_provider.dart';

class NotificationInitializationService {
  static void initialize(WidgetRef ref) {
      print('🚀 Initializing notification...');

    // Initialize harvest expiry checker
    ref.read(expiringHarvestCheckerProvider);
    
    // Initialize weather alert checker
    ref.read(weatherAlertCheckerProvider);
  }
}