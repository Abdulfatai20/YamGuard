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
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _deletePasswordController =
      TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

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
                onPressed: () => Navigator.of(context).pop(),
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
                  Navigator.of(context).pop();
                  logout();
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

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Change Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _currentPasswordController.clear();
                  _newPasswordController.clear();
                  _confirmPasswordController.clear();
                  Navigator.of(context).pop();
                },
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
                  Navigator.of(context).pop();
                  changePassword();
                },
                child: const Text(
                  'Change Password',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
            backgroundColor: AppColors.white,
          ),
    );
  }

  void _showUpdateUsernameDialog(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    _usernameController.text = currentUser?.displayName ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Update Username',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            content: TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _usernameController.clear();
                  Navigator.of(context).pop();
                },
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
                  Navigator.of(context).pop();
                  updateUsername();
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
            backgroundColor: AppColors.white,
          ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This action cannot be undone. Please enter your password to confirm account deletion.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _deletePasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _deletePasswordController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.secondary900),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.of(context).pop();
                  deleteAccount();
                },
                child: const Text(
                  'Delete Account',
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
            e.message ?? 'An error occurred.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unexpected error occurred.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match', Colors.red);
      return;
    }

    if (_newPasswordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters', Colors.red);
      return;
    }

    final auth = ref.read(authServiceProvider);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser?.email == null) {
      _showSnackBar('User email not found', Colors.red);
      return;
    }

    try {
      await auth.resetPasswordFromCurrentPassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        email: currentUser!.email!,
      );
      if (!mounted) return;
      _showSnackBar('Password changed successfully', AppColors.primary700);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'An error occurred';
      if (e.code == 'wrong-password') {
        message = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        message = 'New password is too weak';
      }
      _showSnackBar(e.message ?? message, Colors.red);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Unexpected error occurred', Colors.red);
    } finally {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  Future<void> updateUsername() async {

    if (_usernameController.text.trim().isEmpty) {
      _showSnackBar('Username cannot be empty', Colors.red);
      return;
    }

    final auth = ref.read(authServiceProvider);
    try {
      await auth.updateUserName(_usernameController.text.trim());
      if (!mounted) return;
      _showSnackBar('Username updated successfully', Colors.green);
      setState(() {}); // Refresh the UI to show the new username
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message ?? 'Failed to update username', Colors.red);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Unexpected error occurred', Colors.red);
    } finally {
      _usernameController.clear();
    }
  }

  Future<void> deleteAccount() async {
    if (_deletePasswordController.text.isEmpty) {
      _showSnackBar('Please enter your password', Colors.red);
      return;
    }

    final auth = ref.read(authServiceProvider);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser?.email == null) {
      _showSnackBar('User email not found', Colors.red);
      return;
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
        settings: const RouteSettings(arguments: 'account_deleted'),
      ),
      (route) => false,
    );

    try {
      await auth.deleteAccount(
        email: currentUser!.email!,
        password: _deletePasswordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Failed to delete account';
      if (e.code == 'wrong-password') {
        message = 'Password is incorrect';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unexpected error occurred',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _deletePasswordController.clear();
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final displayName = currentUser?.displayName ?? 'User';

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
        toolbarHeight: 92,
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
                              Text(
                                'Hi $displayName',
                                style: const TextStyle(
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
                              const Text(
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
                                text: 'Change Password',
                                onPressed:
                                    () => _showChangePasswordDialog(context),
                              ),
                              const SizedBox(height: 20),
                              OutlinedShadowButton(
                                text: 'Update Username',
                                onPressed:
                                    () => _showUpdateUsernameDialog(context),
                              ),
                              const SizedBox(height: 20),
                              OutlinedShadowButton(
                                text: 'Delete Account',
                                onPressed:
                                    () => _showDeleteAccountDialog(context),
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
