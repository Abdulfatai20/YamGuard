import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/helpers/weather_feel_helper.dart';
import 'package:yam_guard/providers/weather_provider.dart';
import 'package:yam_guard/themes/colors.dart';

class WeatherForecastWidget extends ConsumerWidget {
  const WeatherForecastWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherData = ref.watch(weatherProvider); // Watch the weatherProvider

    // Date Format
    String formattedDate = DateFormat('MMMM, d').format(DateTime.now());

    return weatherData.when(
      data: (data) {
        // Data is fetched successfully, now you can use the data
        final currentWeather = data['current']; // current weather data
        // final description =
        //     currentWeather['weather'][0]['description']; // Get the weather description
        final temperature =
            currentWeather['temp'].round(); // Get and round the temperature

        final feel = getFeelsLikeWeather(data); // Get the weather feel

        // Capitalize the first letter of each word in the description
        // String formattedDescription = description
        //     .split(' ')
        //     .map((word) {
        //       return word[0].toUpperCase() + word.substring(1);
        //     })
        //     .join(' ');

        return // Content container
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '$feel, $temperature°',
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.primary700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Today - $formattedDate',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color:
                        AppColors
                            .primary700, // lighter color for subtext if needed
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading:
          () => const Center(
            child: CircularProgressIndicator(),
          ), // Show a loading spinner while fetching data
      error:
          (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Column(
                children: [
                  Text(
                    'Check your internet',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Today - $formattedDate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary700,
                    ),
                  ),
                ],
              ),
            ),
          ), // Error handling
    );
  }
}
