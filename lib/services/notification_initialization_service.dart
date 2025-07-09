import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/providers/notification_provider.dart';

class NotificationInitializationService {
  static void initialize(WidgetRef ref) {
      print('🚀 Initializing notification...');
    
    // Initialize weather alert checker
    ref.read(weatherAlertCheckerProvider);
  }
}