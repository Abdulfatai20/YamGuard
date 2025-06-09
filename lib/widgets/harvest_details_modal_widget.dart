// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yam_guard/actions/harvest_action.dart';
import 'package:yam_guard/themes/colors.dart';

class HarvestDetailsModal extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final WidgetRef ref;

  const HarvestDetailsModal({
    super.key,
    required this.data,
    required this.docId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final expiryDate = (data['expiryDate'] as Timestamp).toDate();
    final harvestDate = (data['harvestDate'] as Timestamp).toDate();
    final alertDate = (data['alertDate'] as Timestamp).toDate();
    final storageMethod = data['storageMethod'] as String;
    final totalHarvested = data['totalHarvested'] as int;
    final freshTubers = data['freshTubers'] as int? ?? 0;
    final bruisedTubers = data['bruisedTubers'] as int? ?? 0;
    final lossPercentage = data['lossPercentage'] as int? ?? 0;
    final damagePercentage = data['damagePercentage'] as int? ?? 0;
    final actualLoss = data['actualLoss'] as int? ?? 0;
    final adjustedShelfLifeDays = data['adjustedShelfLifeDays'] as int? ?? 0;
    final originalShelfLifeDays = data['originalShelfLifeDays'] as int? ?? 0;

    final now = DateTime.now();
    final daysToExpiry = expiryDate.difference(now).inDays;
    final isExpiringSoon = now.isAfter(alertDate);

    Widget buildDetailRow(String label, String value, {Color? valueColor}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secondary900.withOpacity(0.7),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.secondary900,
              ),
            ),
          ],
        ),
      );
    }

    Widget buildDetailSection(String title, List<Widget> children) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(children: children),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 50),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary700),
                      const SizedBox(width: 8),
                      Text(
                        'Harvest Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isExpiringSoon ? Colors.orange.withOpacity(0.1) : AppColors.primary700.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isExpiringSoon ? Colors.orange.withOpacity(0.3) : AppColors.primary700.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isExpiringSoon ? Icons.warning_amber : Icons.check_circle,
                          color: isExpiringSoon ? Colors.orange : AppColors.primary700,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isExpiringSoon ? 'Expiring Soon' : 'Fresh',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isExpiringSoon ? Colors.orange : AppColors.primary700,
                          ),
                        ),
                        Text(
                          '$daysToExpiry days remaining',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.secondary900.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Details
                  buildDetailSection('Basic Information', [
                    buildDetailRow('Harvest Date', DateFormat('MMM d, yyyy').format(harvestDate)),
                    buildDetailRow('Expiry Date', DateFormat('MMM d, yyyy').format(expiryDate)),
                    buildDetailRow('Alert Date', DateFormat('MMM d, yyyy').format(alertDate)),
                    buildDetailRow('Storage Method', storageMethod),
                  ]),

                  const SizedBox(height: 20),

                  buildDetailSection('Harvest Summary', [
                    buildDetailRow('Total Harvested', '$totalHarvested tubers'),
                    buildDetailRow('Fresh Tubers', '$freshTubers tubers'),
                    buildDetailRow('Bruised Tubers', '$bruisedTubers tubers'),
                    buildDetailRow('Lost Tubers', '$actualLoss tubers'),
                  ]),

                  const SizedBox(height: 20),

                  buildDetailSection('Loss Analysis', [
                    buildDetailRow('Loss Percentage', '$lossPercentage%',
                        valueColor: lossPercentage > 20
                            ? Colors.red
                            : lossPercentage > 10
                                ? Colors.orange
                                : AppColors.primary700),
                    buildDetailRow('Damage Percentage', '$damagePercentage%',
                        valueColor: damagePercentage > 30
                            ? Colors.red
                            : damagePercentage > 15
                                ? Colors.orange
                                : AppColors.primary700),
                  ]),

                  const SizedBox(height: 20),

                  buildDetailSection('Storage Details', [
                    buildDetailRow('Original Shelf Life', '$originalShelfLifeDays days'),
                    buildDetailRow('Adjusted Shelf Life', '$adjustedShelfLifeDays days'),
                    if (originalShelfLifeDays != adjustedShelfLifeDays)
                      buildDetailRow(
                        'Adjustment',
                        '${((adjustedShelfLifeDays - originalShelfLifeDays) / originalShelfLifeDays * 100).toStringAsFixed(1)}%',
                        valueColor: adjustedShelfLifeDays < originalShelfLifeDays ? Colors.red : AppColors.primary700,
                      ),
                  ]),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.primary700),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(color: AppColors.primary700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            HarvestActions.showActionMenu(context, ref, docId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary700,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Actions',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
