// Updated history_widget.dart with tap functionality
// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yam_guard/actions/harvest_action.dart';
import 'package:yam_guard/providers/firestore_provider.dart';
import 'package:yam_guard/themes/colors.dart';
import 'package:yam_guard/widgets/history_details_modal_widget.dart'; // Add this import

class HistoryWidget extends ConsumerWidget {
  const HistoryWidget({super.key});

  // Add this method to show history details
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

            // Combined stream from multiple collections
            StreamBuilder<List<QuerySnapshot>>(
              stream: _getCombinedHistoryStream(firestore),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary700,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Text(
                    'Error loading history',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Text(
                    'No history items yet',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary900,
                    ),
                  );
                }

                // Combine and sort all documents by completion/expiry date
                final allDocs = <Map<String, dynamic>>[];
                final snapshots = snapshot.data!;

                for (int i = 0; i < snapshots.length; i++) {
                  final querySnapshot = snapshots[i];
                  final collectionName = _getCollectionName(i);

                  for (final doc in querySnapshot.docs) {
                    final data = doc.data() as Map<String, dynamic>;

                    // Safe date extraction for sorting
                    final sortDate = _getSortDate(data);

                    if (sortDate != null) {
                      allDocs.add({
                        'doc': doc,
                        'data': data,
                        'collection': collectionName,
                        'sortDate': sortDate,
                      });
                    }
                  }
                }

                if (allDocs.isEmpty) {
                  return Text(
                    'No history items yet',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary900,
                    ),
                  );
                }

                // Sort by most recent first
                allDocs.sort((a, b) {
                  final aDate = (a['sortDate'] as Timestamp).toDate();
                  final bDate = (b['sortDate'] as Timestamp).toDate();
                  return bDate.compareTo(aDate);
                });

                // Take only the latest 10 items
                final displayDocs = allDocs.take(10).toList();
                final now = DateTime.now();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: displayDocs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final doc = item['doc'];
                    final data = item['data'] as Map<String, dynamic>;
                    final collection = item['collection'] as String;
                    final status = data['status'] as String? ?? 'completed';

                    // Safe date extraction for display
                    final displayDate = _getDisplayDate(data);
                    final storageMethod =
                        data['storageMethod'] as String? ?? 'Unknown';
                    final totalHarvested =
                        data['totalHarvested'] as int? ?? 0;

                    final showBorder =
                        displayDocs.length > 1 &&
                        index < displayDocs.length - 1;

                    // Get status info
                    final statusInfo = _getStatusInfo(
                      status,
                      displayDate,
                      now,
                    );

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
                              onTap: () =>
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

  // Helper method to safely extract sort date
  Timestamp? _getSortDate(Map<String, dynamic> data) {
    // Try different possible timestamp fields
    final candidates = [
      data['completedAt'],
      data['completedDate'],
      data['movedToExpiredAt'],
      data['expiryDate'],
      data['updatedAt'],
      data['createdAt'],
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate is Timestamp) {
        return candidate;
      }
    }
    return null;
  }

  // Helper method to safely extract display date
  DateTime? _getDisplayDate(Map<String, dynamic> data) {
    final sortDate = _getSortDate(data);
    return sortDate?.toDate();
  }

  // Combine streams from different collections
  Stream<List<QuerySnapshot>> _getCombinedHistoryStream(
    FirebaseFirestore firestore,
  ) {
    return Stream.periodic(Duration(seconds: 1), (i) => i).asyncMap((_) async {
      final futures = [
        firestore
            .collection('expiredHarvests')
            .orderBy('movedToExpiredAt', descending: true)
            .limit(5)
            .get()
            .catchError(
              (e) =>
                  firestore
                      .collection('expiredHarvests')
                      .orderBy('expiryDate', descending: true)
                      .limit(5)
                      .get(),
            ),
        firestore
            .collection('consumedHarvests')
            .orderBy('completedAt', descending: true)
            .limit(5)
            .get()
            .catchError(
              (e) => firestore.collection('consumedHarvests').limit(5).get(),
            ),
        firestore
            .collection('soldHarvests')
            .orderBy('completedAt', descending: true)
            .limit(5)
            .get()
            .catchError(
              (e) => firestore.collection('soldHarvests').limit(5).get(),
            ),
      ];

      return await Future.wait(futures);
    });
  }

  String _getCollectionName(int index) {
    switch (index) {
      case 0:
        return 'expiredHarvests';
      case 1:
        return 'consumedHarvests';
      case 2:
        return 'soldHarvests';
      default:
        return 'expiredHarvests';
    }
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