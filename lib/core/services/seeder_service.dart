import 'package:cloud_firestore/cloud_firestore.dart';

class SeederService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedDatabase() async {
    try {
      print('Iniciando Seeder...');
    
    // 1. Seed Animals
    print('Sembrando colección de Animales...');
    final animals = [
        {
          'name': 'Simba',
          'species': 'León Africano',
          'enclosureId': 'Sabana A1',
          'lastCheckup': Timestamp.now(),
          'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Lion_waiting_in_Namutoni.jpg/1200px-Lion_waiting_in_Namutoni.jpg',
        },
        {
          'name': 'Dumbo',
          'species': 'Elefante Africano',
          'enclosureId': 'Sabana B2',
          'lastCheckup': Timestamp.now(),
          'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/African_Elephant_female_and_calf.jpg/1200px-African_Elephant_female_and_calf.jpg',
        },
        {
          'name': 'Kovalsky',
          'species': 'Pingüino de Humboldt',
          'enclosureId': 'Zona Fría C1',
          'lastCheckup': Timestamp.now(),
          'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/2/2b/Humboldt_Penguin_IC.jpg',
        },
        {
          'name': 'Melman',
          'species': 'Jirafa Reticulada',
          'enclosureId': 'Sabana A2',
          'lastCheckup': Timestamp.now(),
          'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/9/9e/Giraffe_Mikumi_National_Park.jpg',
        },
      ];

      for (var animal in animals) {
        await _db.collection('animals').add(animal);
      }

    // 2. Seed Inventory
    print('Sembrando colección de Inventario...');
    final inventoryItems = [
        {
          'name': 'Carne de Res',
          'category': 'Alimentos',
          'quantity': 150,
          'unit': 'kg',
          'minThreshold': 50,
        },
        {
          'name': 'Heno de Alfalfa',
          'category': 'Alimentos',
          'quantity': 800,
          'unit': 'kg',
          'minThreshold': 200,
        },
        {
          'name': 'Antibióticos G1',
          'category': 'Medicinas',
          'quantity': 15,
          'unit': 'unidades',
          'minThreshold': 5,
        },
        {
          'name': 'Pescado Mixto',
          'category': 'Alimentos',
          'quantity': 40,
          'unit': 'kg',
          'minThreshold': 20,
        },
      ];

      for (var item in inventoryItems) {
        await _db.collection('inventory').add(item);
      }
    
    print('Seeder completado con éxito.');
    } catch (e) {
      print('ERROR EN EL SEEDER: $e');
    }
  }
}
