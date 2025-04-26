import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/helpers/weather_feel_helper.dart';
import 'package:yam_guard/providers/weather_provider.dart';
import 'package:yam_guard/themes/colors.dart';

class ForecastTipsWidget extends ConsumerWidget {
  const ForecastTipsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherData = ref.watch(weatherProvider);

    return weatherData.when(
      data: (data) {
        final feel = getFeelsLikeWeather(data);

        final tips = _getTipsByFeel(feel);

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
                  color: const Color.fromRGBO(0, 0, 0, 0.25),
                  offset: const Offset(0, 4),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              children: [
                Column(
                  children: [
                    Image.asset('assets/images/megaphone.png', width: 30, height: 30),
                    const SizedBox(height: 10),
                    Text(
                      tips['action'] ?? 'Stay informed.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    Image.asset('assets/images/lightbulb.png', width: 30, height: 30),
                    const SizedBox(height: 10),
                    Text(
                      tips['advice'] ?? 'No special advice today.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const Text("Could not load forecast tips."),
    );
  }

  Map<String, String> _getTipsByFeel(String feel) {
    switch (feel) {
      case 'Sunny':
        return {
          'advice': 'Perfect day for harvesting and sun-drying yams.',
          'action': 'Avoid planting. Monitor soil moisture.',
        };
      case 'Partly cloudy':
        return {
          'advice': 'Mild sunlight is good for growth.',
          'action': 'Inspect for pests and monitor humidity.',
        };
      case 'Rainy':
        return {
          'advice': 'Water is abundant today.',
          'action': 'Avoid field work. Use mulch to protect soil.',
        };
      case 'Harmattan':
        return {
          'advice': 'Dry air helps preserve harvested yams.',
          'action': 'Protect crops and cover storage areas.',
        };
      case 'Stormy Winds':
        return {
          'advice': 'Winds may damage crops.',
          'action': 'Reinforce structures and check for fallen stakes.',
        };
      default:
        return {
          'advice': 'Stable conditions today.',
          'action': 'Proceed with regular farming and checks.',
        };
    }
  }
}
