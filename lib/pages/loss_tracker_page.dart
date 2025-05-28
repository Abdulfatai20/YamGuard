import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yam_guard/providers/firestore_provider.dart';
import 'package:yam_guard/reuse/underline_white_form.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/dashboard_widget.dart';
import 'package:yam_guard/widgets/history_widget.dart';
import 'package:yam_guard/widgets/today_forecast_widget.dart';
import 'dart:async'; // For TimeoutException

class LossTrackerPage extends ConsumerStatefulWidget {
  const LossTrackerPage({super.key});

  @override
  ConsumerState<LossTrackerPage> createState() => _LossTrackerPageState();
}

class _LossTrackerPageState extends ConsumerState<LossTrackerPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _totalHarvestedController =
      TextEditingController();
  final TextEditingController _freshTubersController = TextEditingController();
  final TextEditingController _bruisedTubersController =
      TextEditingController();
  String? selectedStorageMethod;
  bool _isLoading = false;

  // List of yam storage methods you mentioned
  final Map<String, int> storageMethodsWithShelfLife = {
    'Barn Storage': 180, // 6 months
    'Wooden Shelves Storage': 150, // 5 months
    'Pit Storage': 120, // 4 months
    'Ventilated Pit Storage': 150, // 5 months
    'Plastic Bag Storage': 30, // 1 month
    'Refrigeration': 90, // 3 months
    'Indoor Storage': 60, // 2 months
    'Ash or Sawdust Storage': 120, // 4 months
    'Ventilation Crates': 90, // 3 months
    'Burying in the Ground': 180, // 6 months
  };

  List<String> get storageMethods => storageMethodsWithShelfLife.keys.toList();

  @override
  void initState() {
    super.initState();
    // Set current date formatted as yyyy-MM-dd or whichever format you prefer
    _dateController.text = DateFormat('MMM d, yyyy').format(DateTime.now());
  }

  @override
  void dispose() {
    _dateController.dispose();
    _totalHarvestedController.dispose();
    _freshTubersController.dispose();
    _bruisedTubersController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  DateTime calculateExpiryDate(DateTime harvestDate) {
    // Storage method is required and validated, so it should never be null
    int shelfLifeDays = storageMethodsWithShelfLife[selectedStorageMethod!]!;

    // Consider the condition of tubers for calculation
    final totalHarvested = int.tryParse(_totalHarvestedController.text) ?? 0;
    final bruisedTubers = int.tryParse(_bruisedTubersController.text) ?? 0;

    // Calculate damage percentage for more granular shelf life adjustment
    final damagePercentage =
        totalHarvested > 0 ? (bruisedTubers / totalHarvested) * 100 : 0;

    // Adjust shelf life based on damage level
    if (damagePercentage > 50) {
      shelfLifeDays =
          (shelfLifeDays * 0.6).round(); // 40% reduction for severe damage
    } else if (damagePercentage > 30) {
      shelfLifeDays =
          (shelfLifeDays * 0.75).round(); // 25% reduction for high damage
    } else if (damagePercentage > 15) {
      shelfLifeDays =
          (shelfLifeDays * 0.9).round(); // 10% reduction for moderate damage
    }
    // No reduction for damage ≤ 15%

    return harvestDate.add(Duration(days: shelfLifeDays));
  }

  Future<void> saveHarvestDataToFirestore(WidgetRef ref) async {
    try {
      print('Starting save operation...');
      setState(() {
        _isLoading = true;
      });

      print('Getting firestore instance...');
      final firestore = ref.read(firestoreProvider);

      print('Parsing dates...');
      final harvestDate = DateTime.parse(_dateController.text);
      if (!mounted) return; // check if still mounted after async operation
      final expiryDate = calculateExpiryDate(harvestDate);
      print('Harvest date: $harvestDate, Expiry date: $expiryDate');

      // Calculate loss percentage
      print('Calculating values...');
      final totalHarvested = int.parse(_totalHarvestedController.text);
      final freshTubers = int.parse(_freshTubersController.text);
      final bruisedTubers = int.parse(_bruisedTubersController.text);

      print(
        'Total: $totalHarvested, Fresh: $freshTubers, Bruised: $bruisedTubers',
      );

      // Calculate actual loss (tubers that are completely unusable)
      final actualLoss = totalHarvested - (freshTubers + bruisedTubers);
      final lossPercentage =
          totalHarvested > 0
              ? ((actualLoss / totalHarvested) * 100).round()
              : 0;

      // Calculate damage percentage (bruised tubers)
      final damagePercentage =
          totalHarvested > 0
              ? ((bruisedTubers / totalHarvested) * 100).round()
              : 0;

      print('Loss: $actualLoss ($lossPercentage%), Damage: $damagePercentage%');

      final data = {
        'harvestDate': Timestamp.fromDate(harvestDate),
        'expiryDate': Timestamp.fromDate(expiryDate),
        'totalHarvested': totalHarvested,
        'freshTubers': freshTubers,
        'bruisedTubers': bruisedTubers,
        'storageMethod': selectedStorageMethod,
        'originalShelfLifeDays':
            storageMethodsWithShelfLife[selectedStorageMethod],
        'adjustedShelfLifeDays': expiryDate.difference(harvestDate).inDays,
        'lossPercentage': lossPercentage,
        'damagePercentage': damagePercentage,
        'actualLoss': actualLoss,
        'alertDate': Timestamp.fromDate(expiryDate.subtract(Duration(days: 2))),
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      print('Data prepared: $data');
      print('Attempting to save to Firestore...');

      // Add timeout to the Firestore operation
      await firestore
          .collection('yamHarvests')
          .add(data)
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException(
                'Firestore operation timed out',
                Duration(seconds: 10),
              );
            },
          );

      print('Successfully saved to Firestore!');

      // Clear form after successful save
      _clearForm();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Harvest data saved! Expiry date: ${DateFormat('MMM dd, yyyy').format(expiryDate)}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: AppColors.primary700,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error saving to Firestore: $e');
      print('Error type: ${e.runtimeType}');

      String errorMessage = 'Error saving data';
      if (e is TimeoutException) {
        errorMessage = 'Connection timeout - check your internet';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied - check Firestore rules';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error - check connection';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: TextStyle(color: AppColors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      print('Cleaning up...');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearForm() {
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _totalHarvestedController.clear();
    _freshTubersController.clear();
    _bruisedTubersController.clear();
    setState(() {
      selectedStorageMethod = null;
    });
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
          child: Form(
            key: _formKey,
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
                          GestureDetector(
                            onTap: _selectDate,
                            child: AbsorbPointer(
                              child: TextFormField(
                                decoration: whiteBorderDecoration(
                                  'Harvest Date',
                                ),
                                style: const TextStyle(color: AppColors.white),
                                controller: _dateController,
                              ),
                            ),
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            decoration: whiteBorderDecoration(
                              'Total Harvested Tubers',
                            ),
                            style: const TextStyle(color: AppColors.white),
                            keyboardType: TextInputType.number,
                            controller: _totalHarvestedController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter total harvested tubers';
                              }
                              final numValue = int.tryParse(value);
                              if (numValue == null || numValue < 0) {
                                return 'Enter a valid number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            decoration: whiteBorderDecoration('Fresh Tubers'),
                            controller: _freshTubersController,
                            style: const TextStyle(color: AppColors.white),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final total =
                                  int.tryParse(
                                    _totalHarvestedController.text,
                                  ) ??
                                  0;
                              final fresh = int.tryParse(value ?? '');
                              if (value == null || value.isEmpty) {
                                return 'Enter fresh tubers count';
                              }
                              if (fresh == null || fresh < 0 || fresh > total) {
                                return 'Must be ≤ total harvested';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            decoration: whiteBorderDecoration(
                              'Bruised/Semi-damaged tubers',
                            ),
                            controller: _bruisedTubersController,
                            style: const TextStyle(color: AppColors.white),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final total =
                                  int.tryParse(
                                    _totalHarvestedController.text,
                                  ) ??
                                  0;
                              final fresh =
                                  int.tryParse(_freshTubersController.text) ??
                                  0;
                              final bruised = int.tryParse(value ?? '');
                              if (value == null || value.isEmpty) {
                                return 'Enter bruised tubers count';
                              }
                              if (bruised == null ||
                                  bruised < 0 ||
                                  bruised > total) {
                                return 'Must be ≤ total harvested';
                              }
                              if ((fresh + bruised) > total) {
                                return 'Fresh + Bruised cannot exceed total';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.0),
                          DropdownButtonFormField(
                            value: selectedStorageMethod,
                            dropdownColor: AppColors.secondary500,
                            iconEnabledColor: AppColors.white,
                            decoration: whiteBorderDecoration('Storage Method'),
                            style: const TextStyle(color: AppColors.white),
                            borderRadius: BorderRadius.circular(30),
                            items:
                                storageMethods.map((method) {
                                  return DropdownMenuItem(
                                    value: method,
                                    child: Text(
                                      '$method (${storageMethodsWithShelfLife[method]})',
                                      style: TextStyle(color: AppColors.white),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedStorageMethod = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Select a storage method';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 30.0),
                          SizedBox(
                            height: 35,
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                              ),
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () async {
                                        if (_formKey.currentState!.validate()) {
                                          await saveHarvestDataToFirestore(ref);
                                          print('Form is valid');
                                        } else {
                                          print('Form is invalid');
                                        }
                                      },
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: AppColors.white,
                                        ),
                                      )
                                      : const Text(
                                        'Calculate',
                                        style: TextStyle(
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
                SizedBox(height: 20.0),
                ExpiryDashboard( 
                 
                ),
                SizedBox(height: 30.0),

                HistoryWidget(),

                SizedBox(height: 30.0),

                TodayForecastWidget(),

                SizedBox(height: 10.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
