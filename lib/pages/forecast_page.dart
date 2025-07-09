import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/providers/next_forecast_provider.dart';
import 'package:yam_guard/widgets/today_forecast_widget.dart';
import 'package:yam_guard/widgets/next_forecast_widget.dart';
import 'package:yam_guard/themes/colors.dart';

class ForecastPage extends ConsumerWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastData = ref.watch(forecastProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary700,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Weather Forecast',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TodayForecastWidget(),
              const SizedBox(height: 30),
              forecastData.when(
                data: (forecastItems) =>
                    NextForecastPage(forecastItems: forecastItems),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Failed to load forecast data',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
