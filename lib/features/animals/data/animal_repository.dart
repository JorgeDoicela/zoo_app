import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/database_service.dart';
import '../domain/animal_model.dart';
import '../domain/care_log_model.dart';

class AnimalRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseService _localDb;

  AnimalRepository(this._localDb);

  // Obtener la lista de animales en tiempo real
  Stream<List<Animal>> getAnimals() {
    return _db.collection('animals').snapshots().map((snapshot) {
      final animals = snapshot.docs
          .map((doc) => Animal.fromFirestore(doc.data(), doc.id))
          .toList();
      
      // Cacheamos localmente en segundo plano (Solo si no es web)
      if (!kIsWeb) {
        _cacheAnimals(animals);
      }
      
      return animals;
    });
  }

  // Obtener de la caché local (offline)
  Future<List<Animal>> getLocalAnimals() async {
    if (kIsWeb) return [];
    final maps = await _localDb.query('animals');
    return maps.map((m) => Animal.fromSqlite(m)).toList();
  }

  Future<void> _cacheAnimals(List<Animal> animals) async {
    if (kIsWeb) return;
    for (var animal in animals) {
      await _localDb.insert('animals', animal.toSqlite());
    }
  }

  // Obtener animales filtrados por recinto
  Stream<List<Animal>> getAnimalsByEnclosure(String enclosureId) {
    return _db
        .collection('animals')
        .where('enclosureId', isEqualTo: enclosureId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Animal.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  // Agregar un nuevo animal al zoológico
  Future<void> addAnimal(Animal animal) async {
    // Primero a Firestore
    final docRef = await _db.collection('animals').add(animal.toFirestore());
    // Luego actualizamos la caché local con el ID real si fuera necesario, 
    // pero Firestore snapshots ya lo harán automáticamente al refrescar.
  }

  // Actualizar datos de un animal
  Future<void> updateAnimal(Animal animal) async {
    await _db.collection('animals').doc(animal.id).update(animal.toFirestore());
    if (!kIsWeb) {
      await _localDb.insert('animals', animal.toSqlite());
    }
  }

  // Eliminar un animal
  Future<void> deleteAnimal(String animalId) async {
    await _db.collection('animals').doc(animalId).delete();
    if (!kIsWeb) {
      await _localDb.delete('animals', where: 'id = ?', whereArgs: [animalId]);
    }
  }

  // --- BITÁCORA DE CUIDADOS ---

  // Obtener bitácora de cuidados de un animal
  Stream<List<CareLog>> getCareLogs(String animalId) {
    return _db
        .collection('animals')
        .doc(animalId)
        .collection('care_logs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final logs = snapshot.docs
          .map((doc) => CareLog.fromFirestore(doc.data(), doc.id))
          .toList();
      
      // Cacheamos logs
      if (!kIsWeb) {
        _cacheLogs(logs);
      }
      
      return logs;
    });
  }

  Future<void> _cacheLogs(List<CareLog> logs) async {
    if (kIsWeb) return;
    for (var log in logs) {
      await _localDb.insert('care_logs', log.toSqlite());
    }
  }

  // Agregar entrada a la bitácora
  Future<void> addCareLog(String animalId, CareLog log) async {
    await _db
        .collection('animals')
        .doc(animalId)
        .collection('care_logs')
        .add(log.toFirestore());
        
    await _db.collection('animals').doc(animalId).update({
      'lastCheckup': Timestamp.now(),
    });
  }
}
