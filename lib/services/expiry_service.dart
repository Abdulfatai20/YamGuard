import 'package:cloud_firestore/cloud_firestore.dart';

class ExpiryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // This method moves expired items from activeHarvests to expiredHarvests
  static Future<void> moveExpiredItems() async {
    final now = DateTime.now();
    final batch = _firestore.batch();
    
    try {
      print('🔄 Starting expiry cleanup at ${now.toString()}');
      
      // Get all expired items from activeHarvests
      final expiredQuery = await _firestore
          .collection('activeHarvests')
          .where('expiryDate', isLessThan: Timestamp.fromDate(now))
          .get();
      
      if (expiredQuery.docs.isEmpty) {
        print('✅ No expired items found');
        return;
      }
      
      for (final doc in expiredQuery.docs) {
        final data = doc.data();
        
        // Add to expiredHarvests collection
        final expiredRef = _firestore.collection('expiredHarvests').doc(doc.id);
        batch.set(expiredRef, {
          ...data,
          'movedToExpiredAt': Timestamp.fromDate(now), // Track when moved
        });
        
        // Remove from activeHarvests collection
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('✅ Moved ${expiredQuery.docs.length} expired items successfully');
      
    } catch (e) {
      print('❌ Error moving expired items: $e');
    }
  }
  
  // Helper method to add new harvest to activeHarvests
  static Future<String> addNewHarvest({
    required String storageMethod,
    required int totalHarvested,
    required DateTime expiryDate,
    required DateTime alertDate,
    required String userId,
  }) async {
    final docRef = _firestore.collection('activeHarvests').doc();
    
    await docRef.set({
      'storageMethod': storageMethod,
      'totalHarvested': totalHarvested,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'alertDate': Timestamp.fromDate(alertDate),
      'userId': userId,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'status': 'active',
    });
    
    return docRef.id;
  }
}