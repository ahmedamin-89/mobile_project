class Friend {
  final String id;
  final String name; // Represents the username
  final String email;
  final int numberOfEvents;

  Friend({
    required this.id,
    required this.name,
    required this.email,
    required this.numberOfEvents,
  });

  Friend copyWith({
    String? id,
    String? name,
    String? email,
    int? numberOfEvents,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      numberOfEvents: numberOfEvents ?? this.numberOfEvents,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'username': name,
      'email': email,
      'numberOfEvents': numberOfEvents,
    };
  }

  factory Friend.fromFirestore(Map<String, dynamic> map) {
    return Friend(
      id: map['id'] ?? '',
      name: map['username'] ?? 'Unknown',
      email: map['email'] ?? 'Not Provided',
      numberOfEvents: map['numberOfEvents'] ?? 0,
    );
  }
}
