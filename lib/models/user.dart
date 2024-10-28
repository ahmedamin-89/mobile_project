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

  // Copy method to create a modified copy of the User
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

  // Convert a User object into a Map object for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
    };
  }

  // Create a User object from a Map object retrieved from the database
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      preferences: Map<String, dynamic>.from(map['preferences']),
    );
  }
}
