import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/helpers/weather_feel_helper.dart';
import 'package:yam_guard/helpers/tips_helper.dart';
import 'package:yam_guard/providers/weather_provider.dart';
import 'package:yam_guard/themes/colors.dart';

class ForecastTipsWidget extends ConsumerWidget {
  const ForecastTipsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherData = ref.watch(weatherProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.primary100),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Action Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/megaphone.png',
                  width: 30.0,
                  height: 30.0,
                ),
                const SizedBox(height: 10),
                weatherData.when(
                  data: (data) {
                    final feel = getFeelsLikeWeather(data);
                    final tips = getTipsByFeel(feel);
                    return Text(
                      tips['action'] ?? 'Stay informed.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary900,
                      ),
                    );
                  },
                  loading: () => Text(
                    'Loading forecast tips...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary900,
                    ),
                  ),
                  error: (e, _) => Text(
                    'Could not load forecast tips.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Advice Column
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/lightbulb.png',
                  width: 30.0,
                  height: 30.0,
                ),
                const SizedBox(height: 10),
                weatherData.when(
                  data: (data) {
                    final feel = getFeelsLikeWeather(data);
                    final tips = getTipsByFeel(feel);
                    return Text(
                      tips['advice'] ?? 'No special advice today.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary900,
                      ),
                    );
                  },
                  loading: () => Text(
                    'Loading forecast advice...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary900,
                    ),
                  ),
                  error: (e, _) => Text(
                    'Could not load forecast advice.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}