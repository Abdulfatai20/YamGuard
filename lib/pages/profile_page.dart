import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/pages/login_page.dart';
import 'package:yam_guard/providers/auth_service_provider.dart';
import 'package:yam_guard/reuse/outlined_shadow_button.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: const Text(
              'Are you sure you want to log out?',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), // dismiss
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.secondary900),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary700,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // dismiss the dialog first
                  logout(); // then logout
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
            backgroundColor: AppColors.white,
          ),
    );
  }

  Future<void> logout() async {
    final auth = ref.read(authServiceProvider);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
        settings: const RouteSettings(arguments: 'logged_out'),
      ),
      (route) => false,
    );
    try {
      await auth.logOut();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'An error occured.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unexpected error occurred.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 46),
          child: Text(
            'Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary700,
            ),
          ),
        ),
        toolbarHeight: 92, // 46 padding + ~46 default height
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),

                        // Profile Info
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/profile-image.png',
                                width: 120,
                                height: 120,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Hi Mahmood',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary900,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Settings',
                                style: TextStyle(
                                  color: AppColors.secondary900,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              OutlinedShadowButton(
                                text: 'Logout',
                                onPressed: () => _showLogoutDialog(context),
                              ),
                              const SizedBox(height: 20),
                              OutlinedShadowButton(
                                text: 'Forget Password',
                                onPressed: () {
                                  // Password reset logic here
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
