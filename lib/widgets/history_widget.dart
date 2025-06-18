// Fixed history_widget.dart - Real-time updates with RxDart
// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart'; // Add this import
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
      builder:
          (context) => HistoryDetailsModal(
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

            // Use multiple StreamBuilders for real-time updates
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getCombinedHistoryStream(firestore, userId),
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
                  children:
                      historyItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final doc = item['doc'];
                        final data = item['data'] as Map<String, dynamic>;
                        final collection = item['collection'] as String;
                        final status =
                            data['status'] as String? ??
                            (collection == 'expiredHarvests'
                                ? 'expired'
                                : collection == 'consumedHarvests'
                                ? 'consumed'
                                : 'sold');

                        final displayDate = item['displayDate'] as DateTime?;
                        final storageMethod =
                            data['storageMethod'] as String? ?? 'Unknown';
                        final totalHarvested =
                            data['totalHarvested'] as int? ?? 0;

                        final showBorder =
                            historyItems.length > 1 &&
                            index < historyItems.length - 1;

                        // Get status info
                        final statusInfo = _getStatusInfo(
                          status,
                          displayDate,
                          now,
                        );

                        return GestureDetector(
                          onTap:
                              () => _showHistoryDetails(
                                context,
                                data,
                                ref,
                                doc.id,
                                collection,
                                status,
                              ),
                          child: Container(
                            decoration:
                                showBorder
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          color: AppColors.secondary900
                                              .withOpacity(0.7),
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
                                      color: statusInfo['color'].withOpacity(
                                        0.3,
                                      ),
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
                                  onTap:
                                      () =>
                                          HarvestActions.showHistoryActionMenu(
                                            context,
                                            ref,
                                            doc.id,
                                            collection,
                                            status,
                                          ),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary900.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.more_vert,
                                      size: 16,
                                      color: AppColors.secondary900.withOpacity(
                                        0.7,
                                      ),
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

  // Create a combined stream that merges all history collections using RxDart
  Stream<List<Map<String, dynamic>>> _getCombinedHistoryStream(
    FirebaseFirestore firestore,
    String userId,
  ) {
    // Get streams from all three collections
    final expiredStream =
        firestore
            .collection('expiredHarvests')
            .where('userId', isEqualTo: userId)
            .snapshots();

    final consumedStream =
        firestore
            .collection('consumedHarvests')
            .where('userId', isEqualTo: userId)
            .snapshots();

    final soldStream =
        firestore
            .collection('soldHarvests')
            .where('userId', isEqualTo: userId)
            .snapshots();

    // Combine all streams using RxDart
    return Rx.combineLatest3(expiredStream, consumedStream, soldStream, (
      QuerySnapshot expired,
      QuerySnapshot consumed,
      QuerySnapshot sold,
    ) {
      final allItems = <Map<String, dynamic>>[];

      // Process expired harvests
      for (final doc in expired.docs) {
        final data = doc.data() as Map<String, dynamic>;
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

      // Process consumed harvests
      for (final doc in consumed.docs) {
        final data = doc.data() as Map<String, dynamic>;
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

      // Process sold harvests
      for (final doc in sold.docs) {
        final data = doc.data() as Map<String, dynamic>;
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

      // Sort by most recent first
      allItems.sort((a, b) {
        final aTime = a['sortTimestamp'] as int;
        final bTime = b['sortTimestamp'] as int;
        return bTime.compareTo(aTime); // Most recent first
      });

      // Return top 10 items
      return allItems.take(10).toList();
    });
  }

  // Helper to extract display date based on collection type
  DateTime? _extractDisplayDate(Map<String, dynamic> data, String type) {
    Timestamp? timestamp;

    switch (type) {
      case 'expired':
        timestamp =
            data['movedToExpiredAt'] as Timestamp? ??
            data['expiryDate'] as Timestamp?;
        break;
      case 'consumed':
      case 'sold':
        timestamp =
            data['completedAt'] as Timestamp? ??
            data['completedDate'] as Timestamp?;
        break;
    }

    // Fallback to other timestamp fields
    timestamp ??=
        data['updatedAt'] as Timestamp? ?? data['createdAt'] as Timestamp?;

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
          'timeText':
              displayDate != null ? _getTimeAgo(now, displayDate) : 'Unknown',
        };
      case 'sold':
        return {
          'prefix': 'Sold',
          'color': Colors.blue,
          'timeText':
              displayDate != null ? _getTimeAgo(now, displayDate) : 'Unknown',
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