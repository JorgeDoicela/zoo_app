import 'package:cloud_firestore/cloud_firestore.dart';

class Animal {
  final String id;
  final String name;
  final String species;
  final String enclosureId;
  final DateTime lastCheckup;
  final String? imageUrl;

  Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.enclosureId,
    required this.lastCheckup,
    this.imageUrl,
  });

  // Convertir de Firestore (Map) a objeto Animal
  factory Animal.fromFirestore(Map<String, dynamic> json, String id) {
    return Animal(
      id: id,
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      enclosureId: json['enclosureId'] ?? '',
      lastCheckup: (json['lastCheckup'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'],
    );
  }

  // Convertir de objeto Animal a Map para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'species': species,
      'enclosureId': enclosureId,
      'lastCheckup': Timestamp.fromDate(lastCheckup),
      'imageUrl': imageUrl,
    };
  }

  // SQLite: Mapeo para base de datos local
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'enclosureId': enclosureId,
      'lastCheckup': lastCheckup.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory Animal.fromSqlite(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      name: map['name'],
      species: map['species'],
      enclosureId: map['enclosureId'],
      lastCheckup: DateTime.parse(map['lastCheckup']),
      imageUrl: map['imageUrl'],
    );
  }
}
