import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';

class NextForecastPage extends StatelessWidget {
  final List<Map<String, String>> forecastItems;
  const NextForecastPage({super.key, required this.forecastItems});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Forecast',
              style: TextStyle(
                color: AppColors.secondary900,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            ...forecastItems.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xB3BFBFBF), // #BFBFBF with 70% opacity
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['date']!,
                        style: TextStyle(
                          color: AppColors.secondary700,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Temp text wrapped with Flexible to share space
                      Flexible(
                        flex: 2,
                        child: Text(
                          item['temp']!,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary900,
                          ),
                        ),
                      ),

                      Image.asset(item['image']!, width: 30, height: 30),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      
    );
  }
}
