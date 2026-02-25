class UserModel {
  final String id;
  final String email;
  final String role; // 'admin' or 'caregiver'
  final String name;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.name,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      email: json['email'] ?? '',
      role: json['role'] ?? 'caregiver',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role,
      'name': name,
    };
  }
}
