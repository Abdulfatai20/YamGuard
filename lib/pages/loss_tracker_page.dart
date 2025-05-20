import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yam_guard/reuse/underline_white_form.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/history_widget.dart';
import 'package:yam_guard/widgets/today_forecast_widget.dart';

class LossTrackerPage extends StatefulWidget {
  const LossTrackerPage({super.key});

  @override
  State<LossTrackerPage> createState() => _LossTrackerPageState();
}

class _LossTrackerPageState extends State<LossTrackerPage> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _totalHarvestedController =
      TextEditingController();
  final TextEditingController _freshTubersController = TextEditingController();
  final TextEditingController _bruisedTubersController =
      TextEditingController();
  String? selectedStorageMethod;
  // List of yam storage methods you mentioned
  final List<String> storageMethods = [
    'Clay Pot Storage',
    'Pit Storage',
    'Plastic Bag Storage',
    'Refrigeration',
    'Chemical Treatment',
  ];
  @override
  void initState() {
    super.initState();
    // Set current date formatted as yyyy-MM-dd or whichever format you prefer
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Padding(
          padding: EdgeInsets.only(top: 46),
          child: Text(
            'Loss Tracker',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary700,
            ),
          ),
        ),
        toolbarHeight: 92, // 46 padding + ~46 default height
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: 50,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary700,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: whiteBorderDecoration('Date'),
                          controller: _dateController,
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          decoration: whiteBorderDecoration(
                            'Total Harvested Tubers',
                          ),
                          controller: _totalHarvestedController,
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          decoration: whiteBorderDecoration('Fresh Tubers'),
                          controller: _freshTubersController,
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          decoration: whiteBorderDecoration(
                            'Bruised/Semi-damaged tubers',
                          ),
                          controller: _bruisedTubersController,
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          decoration: whiteBorderDecoration('Storage Method'),
                        ),
                        SizedBox(height: 30.0),
                        SizedBox(
                          height: 35,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                            ),
                            child: const Text(
                              'Calculate',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.primary700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.0),

              HistoryWidget(),

              SizedBox(height: 30.0),

              TodayForecastWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
