import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/appbar_widget.dart';

// Define a provider for the API call
final yamRecommendationProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, String>>((
      ref,
      params,
    ) async {
      final response = await http.post(
        Uri.parse(
          'http://127.0.0.1:8000/recommendation/',
        ), // Change to your backend URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(params),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(response.body);
      }
    });

class YamIntelligencePage extends ConsumerStatefulWidget {
  const YamIntelligencePage({Key? key}) : super(key: key);

  @override
  ConsumerState<YamIntelligencePage> createState() =>
      _YamIntelligencePageState();
}

class _YamIntelligencePageState extends ConsumerState<YamIntelligencePage> {
  final _formKey = GlobalKey<FormState>();
  String yamType = "White Yam";
  String condition = "whole";
  String interval = "14_day";
  Map<String, String>? _params;

  @override
  Widget build(BuildContext context) {
    final yamTypes = ["White Yam", "Yellow Yam", "Bitter Yam", "Lesser Yam"];
    final intervals = ["14_day", "30_day", "60_day", "90_day"];
    final conditions = ["whole", "cut"];

    final recommendationAsync =
        _params == null ? null : ref.watch(yamRecommendationProvider(_params!));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const AppbarWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary700.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary700.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Get personalized storage recommendations",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondary500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Yam Type Selection
                        const Text(
                          "Select Yam Type",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3.5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: yamTypes.length,
                          itemBuilder: (context, index) {
                            final type = yamTypes[index];
                            final isSelected = yamType == type;
                            return GestureDetector(
                              onTap: () => setState(() => yamType = type),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.primary700
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? AppColors.primary700
                                            : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : AppColors.primary700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // Condition Selection
                        const Text(
                          "Yam Condition",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children:
                              conditions.map((c) {
                                final isSelected = condition == c;
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: c == conditions.first ? 8 : 0,
                                      left: c == conditions.last ? 8 : 0,
                                    ),
                                    child: GestureDetector(
                                      onTap:
                                          () => setState(() => condition = c),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isSelected
                                                  ? AppColors.primary700
                                                  : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? AppColors.primary700
                                                    : Colors.grey.shade300,
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            c.toUpperCase(),
                                            style: TextStyle(
                                              color:
                                                  isSelected
                                                      ? Colors.white
                                                      : AppColors.primary700,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Interval Selection
                        const Text(
                          "Storage Duration",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 3.5,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: intervals.length,
                          itemBuilder: (context, index) {
                            final i = intervals[index];
                            final isSelected = interval == i;
                            return GestureDetector(
                              onTap: () => setState(() => interval = i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.primary700
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? AppColors.primary700
                                            : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    i.replaceAll("_", " ").toUpperCase(),
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : AppColors.primary700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 30),

                        // Get Recommendation Button
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              setState(() {
                                _params = {
                                  "yam_type": yamType,
                                  "condition": condition,
                                  "interval": interval,
                                };
                              });
                            },
                            child: const Text(
                              "Get Recommendation",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Recommendation Results
                if (recommendationAsync != null)
                  recommendationAsync.when(
                    data:
                        (data) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary700.withOpacity(0.2),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary700.withOpacity(0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: AppColors.primary700,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        "Recommendations",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Storage Methods
                                _buildStorageMethodsCard(
                                  data['recommended_storage_methods'] as List,
                                ),

                                const SizedBox(height: 16),

                                // Season
                                // _buildSeasonCard(data['season'].toString()),

                                // const SizedBox(height: 16),

                                // Forecast Summary
                                _buildForecastCard(data['forecast_summary']),

                                // Alerts
                                if (data['alerts'] != null &&
                                    (data['alerts'] as List).isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  _buildAlertsCard(data['alerts'] as List),
                                ],

                                const SizedBox(height: 16),

                                // Explanations
                                _buildExplanationsCard(data['explanations']),
                              ],
                            ),
                          ),
                        ),
                    loading:
                        () => const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary700,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Getting your recommendations...",
                                  style: TextStyle(
                                    color: AppColors.primary700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    error:
                        (err, _) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade600,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Something went wrong",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  err.toString(),
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStorageMethodsCard(List storageMethods) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary700.withOpacity(0.1),
            AppColors.primary700.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary700.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.storage, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Recommended Storage Methods",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Fixed: Used Column instead of Wrap to prevent overflow
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                storageMethods.map((method) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary700,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary700.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      method.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  // Widget _buildSeasonCard(String season) {
  //   String displaySeason =
  //       season.toLowerCase().contains('wet')
  //           ? 'Wet Season'
  //           : season.toLowerCase().contains('dry')
  //           ? 'Dry Season'
  //           : season;

  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(20),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [
  //           Colors.orange.withOpacity(0.1),
  //           Colors.orange.withOpacity(0.05),
  //         ],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           padding: const EdgeInsets.all(8),
  //           decoration: BoxDecoration(
  //             color: Colors.orange,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(
  //             displaySeason == 'Dry Season' ? Icons.wb_sunny : Icons.grain,
  //             color: Colors.white,
  //             size: 18,
  //           ),
  //         ),
  //         const SizedBox(width: 12),
  //         const Text(
  //           "Season: ",
  //           style: TextStyle(
  //             fontWeight: FontWeight.bold,
  //             color: Colors.orange,
  //             fontSize: 16,
  //           ),
  //         ),
  //         Expanded(
  //           child: Text(
  //             displaySeason,
  //             style: TextStyle(
  //               color: Colors.orange.shade700,
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildForecastCard(dynamic forecastData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.withOpacity(0.1), Colors.blue.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Forecast Summary",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
            ),
            child: Text(
              _formatJson(forecastData),
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsCard(List alerts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Important Alerts",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...alerts.map((alert) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alert.toString(),
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildExplanationsCard(dynamic explanations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.purple.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Detailed Explanations",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.purple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildExplanationItems(explanations),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExplanationItems(dynamic explanations) {
    final List<Widget> items = [];

    if (explanations is Map) {
      explanations.forEach((key, value) {
        items.add(
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title (e.g., BARN)
                Text(
                  key.toString().replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: Colors.purple.shade800,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Explanation lines with bullets
                ..._buildBulletLines(value.toString()),
              ],
            ),
          ),
        );
      });
    } else if (explanations is List) {
      for (final item in explanations) {
        items.addAll(_buildBulletLines(item.toString()));
      }
    } else {
      items.addAll(_buildBulletLines(explanations.toString()));
    }

    return items;
  }

  List<Widget> _buildBulletLines(String text) {
    final lines = text.trim().split('\n');
    final List<Widget> widgets = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bullet dot (same as in alert)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.purple.shade600,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Text(
                  trimmed,
                  style: TextStyle(
                    color: Colors.purple.shade700,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  String _formatJson(dynamic jsonData) {
    if (jsonData is Map) {
      return jsonData.entries
          .map(
            (entry) =>
                "${entry.key.toString().replaceAll('_', ' ')}: ${entry.value}",
          )
          .join('\n');
    } else if (jsonData is List) {
      return jsonData.map((item) => "• $item").join('\n');
    } else {
      return jsonData.toString();
    }
  }
}
