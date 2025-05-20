import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🟢 Header - Full width, no padding
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary900,
                  ),
                ),
              ],
            ),

            // 🟢 Main Content - With horizontal padding
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Profile Info
                    Center(
                      child: SizedBox(
                        width: 262,
                        height: 118,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircleAvatar(
                              radius: 59,
                              backgroundImage: AssetImage(
                                'assets/images/profile.png',
                              ),
                              backgroundColor: AppColors.primary700,
                            ),
                            SizedBox(height: 10),
                            Text(
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
                    ),

                    const SizedBox(height: 30),

                    // Buttons
                    Column(
                      children: List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: SizedBox(
                            width: 302,
                            height: 37,
                            child: ElevatedButton(
                              onPressed: () {
                                // Modify later
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary700,
                                elevation: 0,
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
