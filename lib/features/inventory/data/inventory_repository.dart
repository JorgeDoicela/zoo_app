import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/database_service.dart';
import '../domain/inventory_model.dart';

class InventoryRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseService _localDb;

  InventoryRepository(this._localDb);

  Stream<List<InventoryItem>> getItems() {
    return _db.collection('inventory').snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => InventoryItem.fromFirestore(doc.data(), doc.id))
          .toList();

      // Caching
      if (!kIsWeb) {
        _cacheItems(items);
      }
      
      return items;
    });
  }

  Future<void> _cacheItems(List<InventoryItem> items) async {
    if (kIsWeb) return;
    for (var item in items) {
      await _localDb.insert('inventory', item.toSqlite());
    }
  }

  Future<void> addItem(InventoryItem item) async {
    await _db.collection('inventory').add(item.toFirestore());
  }

  Future<void> updateItemQuantity(String id, int newQuantity) async {
    await _db.collection('inventory').doc(id).update({'quantity': newQuantity});
  }

  Future<void> deleteItem(String id) async {
    await _db.collection('inventory').doc(id).delete();
    if (!kIsWeb) {
      await _localDb.delete('inventory', where: 'id = ?', whereArgs: [id]);
    }
  }
}
