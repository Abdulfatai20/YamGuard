import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/pages/app_loading.dart';
import 'package:yam_guard/pages/first_page.dart';
import 'package:yam_guard/pages/login_page.dart';
import 'package:yam_guard/providers/auth_service_provider.dart';


class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return const FirstPage(); // User is logged in
        } else {
          return const LoginPage(); // User is not logged in
        }
      },
      loading: () => const AppLoadingPage(), // Show loading
      error:
          (error, stack) => Scaffold(
            body: Center(
              child: Text(
                'An error occurred',
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              ),
            ),
          ),
    );
  }
}
