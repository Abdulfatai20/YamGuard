import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/auth/auth_wrapper.dart';
import 'package:yam_guard/services/notification_initialization_service.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    NotificationInitializationService.initialize(ref);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.white),
        scaffoldBackgroundColor: AppColors.white,
      ),
      home: const AuthWrapper(),
    );
  }
}
