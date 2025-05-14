import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/widget_tree.dart';
import 'package:flutter/gestures.dart';
import 'package:yam_guard/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.secondary900),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 44.0),
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First Column (Title & Subtitle)
              Column(
                children: const [
                  Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary700, // Yam greens
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Welcome back to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 70), // Space between columns
              // Second Column (Email & Password form fields)
              Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondary500,
                        fontWeight: FontWeight.w500,
                      ),
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondary500,
                        fontWeight: FontWeight.w500,
                      ),
                      border: UnderlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Image.asset(
                          _isPasswordVisible
                              ? 'assets/icons/visibility-on.png'
                              : 'assets/icons/visibility-off.png',
                          width: 15,
                          height: 15,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
                ],
              ),

              const SizedBox(
                height: 40,
              ), // Space between forms and button section
              // Third Container (Log In Button + Signup Text)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WidgetTree(),
                          ),
                          (route) => false, // removes all previous routes
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary700,
                      ),
                      child: const Text(
                        'Log In',
                        style: TextStyle(fontSize: 16, color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary900, // Yam green
                          ),
                        ),
                        TextSpan(
                          text: 'Signup Now',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary700,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignupPage(),
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
