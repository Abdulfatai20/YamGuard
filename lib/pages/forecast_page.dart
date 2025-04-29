import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/providers/next_forecast_provider.dart';
import 'package:yam_guard/providers/weather_provider.dart';
import 'package:yam_guard/helpers/weather_image_helper.dart';
import 'package:yam_guard/helpers/weather_feel_helper.dart';
import 'package:yam_guard/widgets/forecast_tips_widget.dart';
import 'package:yam_guard/widgets/next_forecast_widget.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/appbar_widget.dart';
import 'package:yam_guard/widgets/today_forecast_widget.dart';
import 'package:yam_guard/widgets/weather_forecast_widget.dart';

class ForecastPage extends ConsumerWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherData = ref.watch(weatherProvider);
    final forecastData = ref.watch(forecastProvider); 

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
            const TodayForecastWidget(),
            const SizedBox(height: 20),
            forecastData.when(
              data: (forecastItems) =>
                  NextForecastPage(forecastItems: forecastItems),
              loading: () => const CircularProgressIndicator(),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Failed to load forecast data', style: TextStyle(fontWeight: FontWeight.w500),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
