import 'package:cloud_firestore/cloud_firestore.dart';

class CareLog {
  final String id;
  final String animalId;
  final String note;
  final String caregiverId; // or name
  final DateTime date;
  final String type; // e.g., 'Alimentación', 'Medicina', 'Observación'

  CareLog({
    required this.id,
    required this.animalId,
    required this.note,
    required this.caregiverId,
    required this.date,
    required this.type,
  });

  factory CareLog.fromFirestore(Map<String, dynamic> json, String id) {
    return CareLog(
      id: id,
      animalId: json['animalId'] ?? '',
      note: json['note'] ?? '',
      caregiverId: json['caregiverId'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      type: json['type'] ?? 'Observación',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'animalId': animalId,
      'note': note,
      'caregiverId': caregiverId,
      'date': Timestamp.fromDate(date),
      'type': type,
    };
  }

  // SQLite: Mapeo para base de datos local
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'animalId': animalId,
      'note': note,
      'caregiverId': caregiverId,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory CareLog.fromSqlite(Map<String, dynamic> map) {
    return CareLog(
      id: map['id'],
      animalId: map['animalId'],
      note: map['note'],
      caregiverId: map['caregiverId'],
      date: DateTime.parse(map['date']),
      type: map['type'],
    );
  }
}
