class Friend {
  final String id; // Friend's user ID
  final String name;
  final int upcomingEvents;
  final String phoneNumber; // New field

  Friend({
    required this.id,
    required this.name,
    required this.upcomingEvents,
    required this.phoneNumber,
  });

  Friend copyWith({
    String? id,
    String? name,
    int? upcomingEvents,
    String? phoneNumber,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'upcomingEvents': upcomingEvents,
      'phoneNumber': phoneNumber, // Save phone number to Firestore
    };
  }

  factory Friend.fromFirestore(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      name: map['name'],
      upcomingEvents: map['upcomingEvents'] ?? 0,
      phoneNumber: map['phoneNumber'] ?? '', // Default to empty if missing
    );
  }
}
