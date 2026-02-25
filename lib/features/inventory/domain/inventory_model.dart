class InventoryItem {
  final String id;
  final String name;
  final String category; // 'Alimentos', 'Medicinas', 'Suministros'
  final int quantity;
  final String unit; // 'kg', 'litros', 'unidades'
  final int minThreshold;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minThreshold,
  });

  factory InventoryItem.fromFirestore(Map<String, dynamic> json, String id) {
    return InventoryItem(
      id: id,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      minThreshold: json['minThreshold'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'minThreshold': minThreshold,
    };
  }

  // SQLite: Mapeo para base de datos local
  Map<String, dynamic> toSqlite() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'minThreshold': minThreshold,
    };
  }

  factory InventoryItem.fromSqlite(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      quantity: map['quantity'],
      unit: map['unit'],
      minThreshold: map['minThreshold'],
    );
  }
}
