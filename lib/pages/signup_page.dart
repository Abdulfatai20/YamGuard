import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:yam_guard/pages/login_page.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/widget_tree.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary700, // Yam greens
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Climate forecasting and smart storage solutions for yam farmers',
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
                  const SizedBox(height: 30),
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
                ],
              ),

              const SizedBox(
                height: 40,
              ), // Space between forms and button section
              // Third Container (Sign Up Button + Login Text)
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WidgetTree(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary700,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 16, color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary900, // Yam green
                          ),
                        ),
                        TextSpan(
                          text: 'Login Now',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary700,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LoginPage(),
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
