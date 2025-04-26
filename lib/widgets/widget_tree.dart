import 'package:flutter/material.dart';
import 'package:yam_guard/pages/forecast_page.dart';
import 'package:yam_guard/pages/loss_tracker_page.dart';
import 'package:yam_guard/pages/storage_tips_page.dart';
import 'package:yam_guard/widgets/navbar_widget.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

int _currentIndex = 0;
final List<Widget> _pages = [
  ForecastPage(),
  LossTrackerPage(),
  StorageTipsPage(),
];

class _WidgetTreeState extends State<WidgetTree> {
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
