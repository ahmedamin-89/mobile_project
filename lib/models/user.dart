// lib/models/user.dart
class User {
  final String id;
  final String name;
  final String email;
  final Map<String, dynamic> preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.preferences,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
    };
  }

  factory User.fromFirestore(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      preferences: Map<String, dynamic>.from(map['preferences']),
    );
  }
}
