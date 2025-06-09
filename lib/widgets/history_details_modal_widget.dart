// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yam_guard/actions/harvest_action.dart';
import 'package:yam_guard/themes/colors.dart';

class HistoryDetailsModal extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final String collection;
  final String status;
  final WidgetRef ref;

  const HistoryDetailsModal({
    super.key,
    required this.data,
    required this.docId,
    required this.collection,
    required this.status,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    // Safe date extraction
    final harvestDate = _getDateFromField(data, 'harvestDate');
    final expiryDate = _getDateFromField(data, 'expiryDate');
    final alertDate = _getDateFromField(data, 'alertDate');
    final completedDate = _getCompletedDate();
    
    final storageMethod = data['storageMethod'] as String? ?? 'Unknown';
    final totalHarvested = data['totalHarvested'] as int? ?? 0;
    final freshTubers = data['freshTubers'] as int? ?? 0;
    final bruisedTubers = data['bruisedTubers'] as int? ?? 0;
    final lossPercentage = data['lossPercentage'] as int? ?? 0;
    final damagePercentage = data['damagePercentage'] as int? ?? 0;
    final actualLoss = data['actualLoss'] as int? ?? 0;
    final adjustedShelfLifeDays = data['adjustedShelfLifeDays'] as int? ?? 0;
    final originalShelfLifeDays = data['originalShelfLifeDays'] as int? ?? 0;

    final statusInfo = _getStatusInfo();

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
                      Icon(statusInfo['icon'], color: statusInfo['color']),
                      const SizedBox(width: 8),
                      Text(
                        'History Details',
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
                      color: statusInfo['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusInfo['color'].withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          statusInfo['icon'],
                          color: statusInfo['color'],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          statusInfo['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: statusInfo['color'],
                          ),
                        ),
                        if (completedDate != null)
                          Text(
                            statusInfo['subtitle'],
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondary900.withOpacity(0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Timeline/Dates
                  buildDetailSection('Timeline', [
                    if (harvestDate != null)
                      buildDetailRow('Harvest Date', DateFormat('MMM d, yyyy').format(harvestDate)),
                    if (expiryDate != null)
                      buildDetailRow('Expiry Date', DateFormat('MMM d, yyyy').format(expiryDate)),
                    if (alertDate != null)
                      buildDetailRow('Alert Date', DateFormat('MMM d, yyyy').format(alertDate)),
                    if (completedDate != null)
                      buildDetailRow(
                        _getCompletedDateLabel(),
                        DateFormat('MMM d, yyyy').format(completedDate),
                        valueColor: statusInfo['color'],
                      ),
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
                    if (originalShelfLifeDays != adjustedShelfLifeDays && originalShelfLifeDays > 0)
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
                            HarvestActions.showHistoryActionMenu(
                              context, 
                              ref, 
                              docId, 
                              collection, 
                              status
                            );
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

  // Helper method to safely extract dates
  DateTime? _getDateFromField(Map<String, dynamic> data, String field) {
    final value = data[field];
    if (value != null && value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  // Helper method to get completion date based on status
  DateTime? _getCompletedDate() {
    switch (status) {
      case 'expired':
        return _getDateFromField(data, 'movedToExpiredAt') ?? 
               _getDateFromField(data, 'expiryDate');
      case 'consumed':
      case 'sold':
        return _getDateFromField(data, 'completedAt') ?? 
               _getDateFromField(data, 'updatedAt');
      default:
        return _getDateFromField(data, 'completedAt') ?? 
               _getDateFromField(data, 'updatedAt');
    }
  }

  // Helper method to get completed date label
  String _getCompletedDateLabel() {
    switch (status) {
      case 'expired':
        return 'Expired Date';
      case 'consumed':
        return 'Consumed Date';
      case 'sold':
        return 'Sold Date';
      default:
        return 'Completed Date';
    }
  }

  // Helper method to get status information
  Map<String, dynamic> _getStatusInfo() {
    final completedDate = _getCompletedDate();
    final now = DateTime.now();
    
    switch (status) {
      case 'consumed':
        return {
          'title': 'Consumed',
          'color': Colors.green,
          'icon': Icons.check_circle,
          'subtitle': completedDate != null 
              ? _getTimeAgo(now, completedDate)
              : 'Date unknown',
        };
      case 'sold':
        return {
          'title': 'Sold',
          'color': Colors.blue,
          'icon': Icons.sell,
          'subtitle': completedDate != null 
              ? _getTimeAgo(now, completedDate)
              : 'Date unknown',
        };
      case 'expired':
      default:
        return {
          'title': 'Expired',
          'color': Colors.red,
          'icon': Icons.warning,
          'subtitle': completedDate != null 
              ? _getTimeAgo(now, completedDate)
              : 'Date unknown',
        };
    }
  }

  // Helper method to get time ago text
  String _getTimeAgo(DateTime now, DateTime date) {
    final difference = now.difference(date);
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'A few minutes ago';
      } else if (difference.inHours == 1) {
        return '1 hour ago';
      } else {
        return '${difference.inHours} hours ago';
      }
    } else if (difference.inDays == 1) {
      return '1 day ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    }
  }
}