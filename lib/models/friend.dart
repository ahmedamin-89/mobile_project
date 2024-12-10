class Friend {
  final String id;
  final String name;
  final int upcomingEvents;
  final String phoneNumber;

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
      'phoneNumber': phoneNumber,
    };
  }

  factory Friend.fromFirestore(Map<String, dynamic> map) {
    return Friend(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown',
      upcomingEvents: map['upcomingEvents'] ?? 0,
      phoneNumber: map['phoneNumber'] ?? 'Not Provided',
    );
  }
}
