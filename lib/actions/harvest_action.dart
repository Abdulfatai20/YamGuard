import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yam_guard/auth/auth_service.dart';
import 'package:yam_guard/providers/firestore_provider.dart';
import 'package:yam_guard/themes/colors.dart';

class HarvestActions {
  // Delete harvest permanently from any collection
  static Future<void> _deleteHarvest(
    BuildContext context,
    WidgetRef ref,
    String docId, {
    String collection = 'activeHarvests',
  }) async {
    // Show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Harvest'),
          content: Text(
            'Are you sure you want to delete this harvest record permanently?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        final firestore = ref.read(firestoreProvider);
        final authService = AuthService();
        final userId = authService.currentUser!.uid;

        // Delete only if the document belongs to the current user
        await firestore
            .collection(collection)
            .doc(docId)
            .get()
            .then((doc) async {
          if (doc.exists && doc.data()?['userId'] == userId) {
            await doc.reference.delete();
          } else {
            throw Exception('Document not found or access denied');
          }
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Harvest deleted successfully'),
              backgroundColor: AppColors.primary700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting harvest'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  // Move item from activeHarvests to appropriate collection based on status
  static Future<void> _moveHarvestToHistory(
    BuildContext context,
    WidgetRef ref,
    String docId,
    String newStatus,
  ) async {
    try {
      final firestore = ref.read(firestoreProvider);
      final authService = AuthService();
      final userId = authService.currentUser!.uid;

      // Get the document from activeHarvests and verify ownership
      final docSnapshot = await firestore
          .collection('activeHarvests')
          .doc(docId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Document not found');
      }

      final data = docSnapshot.data()!;
      
      // Check if document belongs to current user
      if (data['userId'] != userId) {
        throw Exception('Access denied');
      }

      // Update the status and timestamp
      data['status'] = newStatus;
      data['updatedAt'] = FieldValue.serverTimestamp();
      data['completedAt'] = FieldValue.serverTimestamp();

      // For expired items, use movedToExpiredAt instead of completedAt
      if (newStatus == 'expired') {
        data['movedToExpiredAt'] = FieldValue.serverTimestamp();
        data.remove('completedAt');
      }

      // Determine target collection based on status
      String targetCollection;
      switch (newStatus) {
        case 'expired':
          targetCollection = 'expiredHarvests';
          break;
        case 'consumed':
          targetCollection = 'consumedHarvests';
          break;
        case 'sold':
          targetCollection = 'soldHarvests';
          break;
        default:
          targetCollection = 'completedHarvests';
      }

      // Use batch write for atomic operation
      final batch = firestore.batch();

      // Add to target collection
      final newDocRef = firestore.collection(targetCollection).doc();
      batch.set(newDocRef, data);

      // Remove from activeHarvests
      batch.delete(firestore.collection('activeHarvests').doc(docId));

      // Commit the batch
      await batch.commit();

      if (context.mounted) {
        String message;
        switch (newStatus) {
          case 'consumed':
            message = 'Marked as consumed and moved to history';
            break;
          case 'sold':
            message = 'Marked as sold and moved to history';
            break;
          case 'expired':
            message = 'Marked as expired and moved to history';
            break;
          default:
            message = 'Status updated successfully';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.primary700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Show action menu for active harvests (dashboard items)
  static void showActionMenu(
    BuildContext context,
    WidgetRef ref,
    String docId,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.check_circle, color: AppColors.primary700),
                title: Text('Mark as Consumed'),
                subtitle: Text('Move to consumed history'),
                onTap: () {
                  Navigator.pop(context);
                  _moveHarvestToHistory(context, ref, docId, 'consumed');
                },
              ),
              ListTile(
                leading: Icon(Icons.sell, color: Colors.blue),
                title: Text('Mark as Sold'),
                subtitle: Text('Move to sales history'),
                onTap: () {
                  Navigator.pop(context);
                  _moveHarvestToHistory(context, ref, docId, 'sold');
                },
              ),
              ListTile(
                leading: Icon(Icons.warning, color: Colors.orange),
                title: Text('Mark as Expired'),
                subtitle: Text('Move to expired history'),
                onTap: () {
                  Navigator.pop(context);
                  _moveHarvestToHistory(context, ref, docId, 'expired');
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Permanently'),
                subtitle: Text('Remove completely'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteHarvest(context, ref, docId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Simplified history action menu - only Restore and Delete
  static void showHistoryActionMenu(
    BuildContext context,
    WidgetRef ref,
    String docId,
    String currentCollection,
    String currentStatus,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.restore, color: AppColors.primary700),
                title: Text('Restore to Active'),
                subtitle: Text('Move back to dashboard'),
                onTap: () {
                  Navigator.pop(context);
                  _restoreToActive(context, ref, docId, currentCollection);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Permanently'),
                subtitle: Text('Remove completely from history'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteHarvest(
                    context,
                    ref,
                    docId,
                    collection: currentCollection,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Restore item back to active harvests
  static Future<void> _restoreToActive(
    BuildContext context,
    WidgetRef ref,
    String docId,
    String currentCollection,
  ) async {
    try {
      final firestore = ref.read(firestoreProvider);
      final authService = AuthService();
      final userId = authService.currentUser!.uid;

      // Get the document from current collection and verify ownership
      final docSnapshot = await firestore
          .collection(currentCollection)
          .doc(docId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Document not found');
      }

      final data = docSnapshot.data()!;
      
      // Check if document belongs to current user
      if (data['userId'] != userId) {
        throw Exception('Access denied');
      }

      // Update the status back to active
      data['status'] = 'active';
      data['updatedAt'] = FieldValue.serverTimestamp();
      data.remove('completedAt'); // Remove completion timestamp
      data.remove('movedToExpiredAt'); // Remove expired timestamp if exists

      // Use batch write for atomic operation
      final batch = firestore.batch();

      // Add back to activeHarvests
      final newDocRef = firestore.collection('activeHarvests').doc();
      batch.set(newDocRef, data);

      // Remove from current collection
      batch.delete(firestore.collection(currentCollection).doc(docId));

      // Commit the batch
      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Harvest restored to active dashboard'),
            backgroundColor: AppColors.primary700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring harvest: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}