import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';


class NextForecastPage extends StatelessWidget {
  final List<Map<String, String>> forecastItems;
  const NextForecastPage({super.key, required this.forecastItems});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Container(
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
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            ...forecastItems.map((item){
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
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item['temp']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondary900,
                            ),
                          ),
                        ],
                      ),
                    
                      Image.asset(item['image']!, width: 30, height: 30),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
