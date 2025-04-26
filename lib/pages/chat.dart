import 'package:flutter/material.dart';

class ForecastPage extends StatelessWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow body to go behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent to show the background
        elevation: 0, // No shadow
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Location icon + "Osogbo" text
            Row(
              children: const [
                Icon(Icons.location_on_outlined, size: 20, color: Colors.white),
                SizedBox(width: 5), // Space between icon and text
                Text(
                  'Osogbo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            // Right: Notification icon
            const Icon(Icons.notifications_none_outlined, color: Colors.white),
          ],
        ),
      ),

      body: Stack(
        children: [
          // Green rectangle (with optional image background)
          Container(
            height: 296,
            decoration: BoxDecoration(
              color: Colors.green, // Your desired background color
              image: DecorationImage(
                image: AssetImage('assets/images/your_image.png'), // Optional image
                fit: BoxFit.cover, // Covers the entire area
              ),
            ),
          ),

          // Main page content (starts below AppBar)
          Padding(
            padding: const EdgeInsets.only(
              top: kToolbarHeight + 24, // Pushes content below AppBar + some space
              left: 44, // Horizontal padding (left)
              right: 44, // Horizontal padding (right)
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  // Your content starts here
                  Text(
                    "Your content starts here...",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  // Add more widgets here
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
