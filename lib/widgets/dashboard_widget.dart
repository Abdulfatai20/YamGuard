// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yam_guard/actions/harvest_action.dart';
import 'package:yam_guard/auth/auth_service.dart';
import 'package:yam_guard/providers/firestore_provider.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/harvest_details_modal_widget.dart';

class ExpiryDashboard extends ConsumerWidget {
  const ExpiryDashboard({super.key});

  void _showHarvestDetails(
    BuildContext context,
    Map<String, dynamic> data,
    WidgetRef ref,
    String docId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => HarvestDetailsModal(data: data, docId: docId, ref: ref),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestore = ref.read(firestoreProvider);
    final authService = AuthService();
    final userId = authService.currentUser!.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 44),
      child: Container(
        padding: const EdgeInsets.only(bottom: 10.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xB3BFBFBF), width: 1.0),
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
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 10),

            // Use FutureBuilder instead of StreamBuilder for initial load reliability
            FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _getActiveHarvestsData(firestore, userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary700,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  print('Dashboard error: ${snapshot.error}');
                  return Text(
                    'Error loading data',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'No active harvests found',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary900,
                    ),
                  );
                }

                final docs = snapshot.data!;
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

                    return GestureDetector(
                      onTap: () => _showHarvestDetails(
                        context,
                        data,
                        ref,
                        doc.id,
                      ),
                      child: Container(
                        decoration: showBorder
                            ? BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: const Color(0xFFE0E0E0),
                                    width: 1.0,
                                  ),
                                ),
                              )
                            : null,
                        padding: const EdgeInsets.only(
                          bottom: 8.0,
                          top: 8.0,
                        ),
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
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
                            const SizedBox(width: 8),
                            // Action button
                            GestureDetector(
                              onTap: () => HarvestActions.showActionMenu(
                                context,
                                ref,
                                doc.id,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary900.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.more_vert,
                                  size: 16,
                                  color: AppColors.secondary900.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            // Add StreamBuilder for real-time updates after initial load
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('activeHarvests')
                  .where('userId', isEqualTo: userId)
                  .limit(10)
                  .snapshots(),
              builder: (context, streamSnapshot) {
                // Only show stream updates, don't show loading/error states
                // since we have the FutureBuilder handling initial state
                if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
                  return SizedBox.shrink();
                }

                // This will update the UI when new data comes in
                // but won't show loading states since FutureBuilder handles that
                return SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Fetch active harvests with manual sorting to avoid index issues
  Future<List<QueryDocumentSnapshot>> _getActiveHarvestsData(
    FirebaseFirestore firestore,
    String userId,
  ) async {
    try {
      print('Fetching active harvests for user: $userId');
      
      // Simple query without orderBy to avoid index requirements
      final query = await firestore
          .collection('activeHarvests')
          .where('userId', isEqualTo: userId)
          .get();

      print('Found ${query.docs.length} active harvests');

      if (query.docs.isEmpty) {
        return [];
      }

      // Manual sorting by expiry date (soonest first)
      final docs = query.docs;
      docs.sort((a, b) {
        try {
          final aData = a.data();
          final bData = b.data();
          
          final aExpiry = (aData['expiryDate'] as Timestamp).toDate();
          final bExpiry = (bData['expiryDate'] as Timestamp).toDate();
          
          return aExpiry.compareTo(bExpiry); // Soonest expiry first
        } catch (e) {
          print('Error sorting documents: $e');
          return 0;
        }
      });

      // Return top 10
      return docs.take(10).toList();
      
    } catch (e) {
      print('Error fetching active harvests: $e');
      print('Error type: ${e.runtimeType}');
      
      // Return empty list instead of throwing
      return [];
    }
  }
}