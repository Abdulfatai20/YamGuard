// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yam_guard/providers/firestore_provider.dart';
import 'package:yam_guard/themes/colors.dart';

class ExpiryDashboard extends ConsumerWidget {
  const ExpiryDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.read(firestoreProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Container(
        padding: const EdgeInsets.only(bottom: 10.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Color(0xB3BFBFBF),
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Expiry Dashboard",
              style: TextStyle(
                color: AppColors.secondary900,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('activeHarvests') // Direct query to active items only
                  .orderBy('expiryDate', descending: false) // Soonest expiry first
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary700),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Error loading data',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text(
                    'No active harvests found',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary900,
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                final now = DateTime.now();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: docs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final doc = entry.value;
                    final data = doc.data() as Map<String, dynamic>;
                    final expiryDate = (data['expiryDate'] as Timestamp).toDate();
                    final alertDate = (data['alertDate'] as Timestamp).toDate();
                    final storageMethod = data['storageMethod'] as String;
                    final totalHarvested = data['totalHarvested'] as int;

                    final daysToExpiry = expiryDate.difference(now).inDays;
                    final isExpiringSoon = now.isAfter(alertDate);

                    Color statusColor = isExpiringSoon ? Colors.orange : Colors.green;
                    String statusText = '$daysToExpiry days left';

                    final showBorder = docs.length > 1 && index < docs.length - 1;

                    return Container(
                      decoration: showBorder ? BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: const Color(0xFFE0E0E0),
                            width: 1.0,
                          ),
                        ),
                      ) : null,
                      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expires: ${DateFormat('MMM d, yyyy').format(expiryDate)}',
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondary900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$storageMethod • $totalHarvested tubers',
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.secondary900.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: statusColor.withOpacity(0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
