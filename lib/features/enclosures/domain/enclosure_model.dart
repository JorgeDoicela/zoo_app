class Enclosure {
  final String id;
  final String name;
  final String type;
  final int capacity;

  Enclosure({
    required this.id,
    required this.name,
    required this.type,
    required this.capacity,
  });

  factory Enclosure.fromFirestore(Map<String, dynamic> json, String id) {
    return Enclosure(
      id: id,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      capacity: json['capacity'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'capacity': capacity,
    };
  }
}
