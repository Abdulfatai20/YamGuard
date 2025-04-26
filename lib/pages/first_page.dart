import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/widget_tree.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WidgetTree()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Yam',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 40,
                      color: AppColors.primary700, // Yam green
                    ),
                  ),
                  TextSpan(
                    text: 'Guard',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 40,
                      color: AppColors.secondary900, // Guard black
                    ),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/images/logo.png',
              width: 43,
              height: 43,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }
}
