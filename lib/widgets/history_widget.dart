// Updated history_widget.dart with simplified and more reliable approach
// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yam_guard/actions/harvest_action.dart';
import 'package:yam_guard/auth/auth_service.dart';
import 'package:yam_guard/providers/firestore_provider.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/history_details_modal_widget.dart';

class HistoryWidget extends ConsumerWidget {
  const HistoryWidget({super.key});

  void _showHistoryDetails(
    BuildContext context,
    Map<String, dynamic> data,
    WidgetRef ref,
    String docId,
    String collection,
    String status,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => HistoryDetailsModal(
        data: data,
        docId: docId,
        collection: collection,
        status: status,
        ref: ref,
      ),
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
              "History",
              style: TextStyle(
                color: AppColors.secondary900,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            // Use FutureBuilder instead of StreamBuilder for more reliability
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getCombinedHistoryData(firestore, userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary700,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  print('History error: ${snapshot.error}');
                  return Text(
                    'Error loading history',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text(
                    'No history items yet',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary900,
                    ),
                  );
                }

                final historyItems = snapshot.data!;
                final now = DateTime.now();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: historyItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final doc = item['doc'];
                    final data = item['data'] as Map<String, dynamic>;
                    final collection = item['collection'] as String;
                    final status = data['status'] as String? ?? 
                        (collection == 'expiredHarvests' ? 'expired' : 
                         collection == 'consumedHarvests' ? 'consumed' : 'sold');

                    final displayDate = item['displayDate'] as DateTime?;
                    final storageMethod = data['storageMethod'] as String? ?? 'Unknown';
                    final totalHarvested = data['totalHarvested'] as int? ?? 0;

                    final showBorder = historyItems.length > 1 && index < historyItems.length - 1;

                    // Get status info
                    final statusInfo = _getStatusInfo(status, displayDate, now);

                    return GestureDetector(
                      onTap: () => _showHistoryDetails(
                        context,
                        data,
                        ref,
                        doc.id,
                        collection,
                        status,
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
                                    displayDate != null
                                        ? '${statusInfo['prefix']}: ${DateFormat('MMM d, yyyy').format(displayDate)}'
                                        : '${statusInfo['prefix']}: Date unavailable',
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
                                color: statusInfo['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: statusInfo['color'].withOpacity(0.3),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                statusInfo['timeText'],
                                style: TextStyle(
                                  color: statusInfo['color'],
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Action button
                            GestureDetector(
                              onTap: () => HarvestActions.showHistoryActionMenu(
                                context,
                                ref,
                                doc.id,
                                collection,
                                status,
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
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  // Simplified approach using Future instead of complex streams
  Future<List<Map<String, dynamic>>> _getCombinedHistoryData(
    FirebaseFirestore firestore,
    String userId,
  ) async {
    final allItems = <Map<String, dynamic>>[];

    try {
      // Get expired harvests - use simpler query without orderBy if index missing
      try {
        final expiredQuery = await firestore
            .collection('expiredHarvests')
            .where('userId', isEqualTo: userId)
            .limit(5)
            .get();
        
        for (final doc in expiredQuery.docs) {
          final data = doc.data();
          final displayDate = _extractDisplayDate(data, 'expired');
          if (displayDate != null) {
            allItems.add({
              'doc': doc,
              'data': data,
              'collection': 'expiredHarvests',
              'displayDate': displayDate,
              'sortTimestamp': _dateToTimestamp(displayDate),
            });
          }
        }
      } catch (e) {
        print('Error fetching expired harvests: $e');
      }

      // Get consumed harvests
      try {
        final consumedQuery = await firestore
            .collection('consumedHarvests')
            .where('userId', isEqualTo: userId)
            .limit(5)
            .get();
        
        for (final doc in consumedQuery.docs) {
          final data = doc.data();
          final displayDate = _extractDisplayDate(data, 'consumed');
          if (displayDate != null) {
            allItems.add({
              'doc': doc,
              'data': data,
              'collection': 'consumedHarvests',
              'displayDate': displayDate,
              'sortTimestamp': _dateToTimestamp(displayDate),
            });
          }
        }
      } catch (e) {
        print('Error fetching consumed harvests: $e');
      }

      // Get sold harvests
      try {
        final soldQuery = await firestore
            .collection('soldHarvests')
            .where('userId', isEqualTo: userId)
            .limit(5)
            .get();
        
        for (final doc in soldQuery.docs) {
          final data = doc.data();
          final displayDate = _extractDisplayDate(data, 'sold');
          if (displayDate != null) {
            allItems.add({
              'doc': doc,
              'data': data,
              'collection': 'soldHarvests',
              'displayDate': displayDate,
              'sortTimestamp': _dateToTimestamp(displayDate),
            });
          }
        }
      } catch (e) {
        print('Error fetching sold harvests: $e');
      }

      // Sort by most recent first
      allItems.sort((a, b) {
        final aTime = a['sortTimestamp'] as int;
        final bTime = b['sortTimestamp'] as int;
        return bTime.compareTo(aTime); // Most recent first
      });

      // Return top 10 items
      return allItems.take(10).toList();
      
    } catch (e) {
      print('Error in _getCombinedHistoryData: $e');
      return [];
    }
  }

  // Helper to extract display date based on collection type
  DateTime? _extractDisplayDate(Map<String, dynamic> data, String type) {
    Timestamp? timestamp;
    
    switch (type) {
      case 'expired':
        timestamp = data['movedToExpiredAt'] as Timestamp? ?? 
                   data['expiryDate'] as Timestamp?;
        break;
      case 'consumed':
      case 'sold':
        timestamp = data['completedAt'] as Timestamp? ?? 
                   data['completedDate'] as Timestamp?;
        break;
    }
    
    // Fallback to other timestamp fields
    timestamp ??= data['updatedAt'] as Timestamp? ?? 
                 data['createdAt'] as Timestamp?;
    
    return timestamp?.toDate();
  }

  // Convert DateTime to milliseconds for sorting
  int _dateToTimestamp(DateTime date) {
    return date.millisecondsSinceEpoch;
  }

  Map<String, dynamic> _getStatusInfo(
    String status,
    DateTime? displayDate,
    DateTime now,
  ) {
    switch (status) {
      case 'consumed':
        return {
          'prefix': 'Consumed',
          'color': Colors.green,
          'timeText': displayDate != null ? _getTimeAgo(now, displayDate) : 'Unknown',
        };
      case 'sold':
        return {
          'prefix': 'Sold',
          'color': Colors.blue,
          'timeText': displayDate != null ? _getTimeAgo(now, displayDate) : 'Unknown',
        };
      case 'expired':
      default:
        if (displayDate != null) {
          final daysExpired = now.difference(displayDate).inDays;
          return {
            'prefix': 'Expired',
            'color': Colors.red,
            'timeText': '${daysExpired}d ago',
          };
        } else {
          return {
            'prefix': 'Expired',
            'color': Colors.red,
            'timeText': 'Unknown',
          };
        }
    }
  }

  String _getTimeAgo(DateTime now, DateTime date) {
    final difference = now.difference(date).inDays;
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return '1d ago';
    } else {
      return '${difference}d ago';
    }
  }
}