import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/pages/app_loading.dart';
import 'package:yam_guard/pages/login_page.dart';
import 'package:yam_guard/widgets/widget_tree.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingPage(); // circular loading screen
        } else if (snapshot.hasData) {
          return const WidgetTree(); // user is logged in
        } else {
          return const LoginPage(); // user not logged in
        }
      },
    );
  }
}