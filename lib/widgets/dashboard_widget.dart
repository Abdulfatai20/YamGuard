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
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: AppColors.primary700,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Expiry Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('yamHarvests')
                  .where('status', isEqualTo: 'active')
                  .orderBy('expiryDate', descending: false)
                  .limit(5)
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
                    style: TextStyle(color: Colors.red),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.grey.shade400,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No active harvests found',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                final now = DateTime.now();

                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final expiryDate = (data['expiryDate'] as Timestamp).toDate();
                    final alertDate = (data['alertDate'] as Timestamp).toDate();
                    final storageMethod = data['storageMethod'] as String;
                    final totalHarvested = data['totalHarvested'] as int;
                    
                    final daysToExpiry = expiryDate.difference(now).inDays;
                    final isExpiringSoon = now.isAfter(alertDate) && now.isBefore(expiryDate);
                    final isExpired = now.isAfter(expiryDate);
                    
                    Color statusColor;
                    String statusText;
                    IconData statusIcon;
                    
                    if (isExpired) {
                      statusColor = Colors.red;
                      statusText = 'EXPIRED';
                      statusIcon = Icons.warning;
                    } else if (isExpiringSoon) {
                      statusColor = Colors.orange;
                      statusText = '$daysToExpiry days left';
                      statusIcon = Icons.access_time;
                    } else {
                      statusColor = Colors.green;
                      statusText = '$daysToExpiry days left';
                      statusIcon = Icons.check_circle;
                    }

                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expires: ${DateFormat('MMMM d, yyyy').format(expiryDate)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '$storageMethod • $totalHarvested tubers',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
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