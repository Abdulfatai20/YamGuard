import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/providers/today_forecast_provider.dart';
import 'package:yam_guard/themes/colors.dart';

class TodayForecastWidget extends ConsumerWidget {
  const TodayForecastWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayForecastData = ref.watch(todayForecastProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Container(
        padding: const EdgeInsets.only(bottom: 10.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Color(0xB3BFBFBF), // #BFBFBF with 70% opacity
              width: 1.0,
            ),
          ),
        ),
        child: todayForecastData.when(
          data:
              (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Forecast",
                    style: TextStyle(
                      color: AppColors.secondary900,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
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
                          data['date']!,
                          style: TextStyle(
                            color: AppColors.secondary700,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              data['temp']!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondary900,
                              ),
                            ),
                          ],
                        ),
                        Image.asset(data['image']!, width: 30, height: 30),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/megaphone.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data['advice']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.secondary700,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, _) => Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Failed to load today’s forecast',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
        ),
      ),
    );
  }
}
