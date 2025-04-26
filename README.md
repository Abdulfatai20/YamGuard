# yam_guard
TODO 
1 - PARTLY SUNNY
2- ERROR IMAGE AND MESSAGE
 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/providers/weather_provider.dart';
import 'package:yam_guard/helpers/weather_image_helper.dart';
import 'package:yam_guard/helpers/weather_feel_helper.dart';
import 'package:yam_guard/widgets/forecast_tips_widget.dart';
import 'package:yam_guard/widgets/next_forecast_widget.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/appbar_widget.dart';
import 'package:yam_guard/widgets/weather_forecast_widget.dart';

class ForecastPage extends ConsumerWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherData = ref.watch(weatherProvider); // Watch the weatherProvider

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppbarWidget(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 296,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:
                        AppColors.primary700, // Your desired background color
                  ),
                ),
                Positioned(
                  top: 130, // Adjust the vertical position
                  left:
                      MediaQuery.of(context).size.width / 2 -
                      75, // Center horizontally (150 / 2 = 75)
                  child: weatherData.when(
                    data: (data) {
                      final feel = getFeelsLikeWeather(
                        data,
                      ); // Get the weather feel
                      final imagePath = getWeatherImageFromFeeling(feel);
                      return Image.asset(
                        imagePath,
                        height: 150.0,
                        width: 150.0,
                        fit: BoxFit.cover,
                      );
                    },
                    loading: () => const SizedBox(
                      height: 150,
                      width: 150,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error:
                        (error, _) => Image.asset(
                          'assets/images/no_internet.png', // your custom image
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const WeatherForecastWidget(),
            const SizedBox(height: 20),
            const ForecastTipsWidget(),
            const SizedBox(height: 30),
            const NextForecastPage(),
          ],
        ),
      ),
    );
  }
} so next is nextforecast page which i want to use dataset before but now, ill rather use historical weathers from openweathermap api, abi wetin you think. this is my nextforecast page import 'package:flutter/material.dart';
import 'package:yam_guard/themes/colors.dart';

import '../data/constants.dart';

class NextForecastPage extends StatelessWidget {
  const NextForecastPage({super.key});

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
            ...List.generate(forecastItems.length, (index) {
              final item = forecastItems[index];
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
                            item['weather']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondary900,
                            ),
                          ),
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
 

String getForecastTip(String feel) {
  switch (feel) {
    case 'sunny':
      return 'Great day to dry harvested yams under sun.';
    case 'partly_cloudy':
      return 'Fair sunlight. Monitor sky before drying.';
    case 'mostly_cloudy':
    case 'cloudy':
      return 'Low sunlight. Store yams in cool, dry place.';
    case 'rainy':
      return 'Rain likely. Keep yams covered and indoors.';
    case 'storm':
      return 'Stormy! Stay safe, no farm work today.';
    case 'windy':
      return 'Dusty air possible. Cover exposed yams.';
    default:
      return 'Check conditions closely before farm activities.';
  }
}


bool feelsSunny(Map<String, dynamic> data) {
  final cloudiness = data['current']['clouds']; // % of sky covered
  final visibility = data['current']['visibility']; // meters
  final uvi = data['current']['uvi']; // UV index
  final now = DateTime.now().millisecondsSinceEpoch / 1000;
  final sunrise = data['current']['sunrise'];
  final sunset = data['current']['sunset'];

  final isDaytime = now > sunrise && now < sunset;
  final isLowCloud = cloudiness <= 30;
  final isHighVisibility = visibility >= 8000;
  final isHighUV = uvi >= 5;

  return isDaytime && (isLowCloud || isHighVisibility || isHighUV);
}  explain this thing wella for me, shey no be every afternoon e go dey give sunny
A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
