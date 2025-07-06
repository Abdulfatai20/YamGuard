import 'package:flutter/material.dart';
import 'package:yam_guard/pages/Yam_intelligence_page.dart';
import 'package:yam_guard/pages/forecast_page.dart';
import 'package:yam_guard/pages/loss_tracker_page.dart';
import 'package:yam_guard/pages/profile_page.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/navbar_widget.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    YamIntelligencePage(),
    ForecastPage(),
    LossTrackerPage(),
    ProfilePage(),
  ];
  bool _showLoginSuccessSnackbar = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == 'logged_in' && !_showLoginSuccessSnackbar) {
      _showLoginSuccessSnackbar = true; // So it only shows once

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Login successful',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.primary700,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      });
      // You cannot reset the arguments directly; consider using a local flag or a state management solution
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavbarWidget(
        selectedIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
