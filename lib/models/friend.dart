// lib/models/friend.dart
class Friend {
  final String id; // Friend's user ID
  final String name;
  final String profileImageUrl;
  final int upcomingEvents;

  Friend({
    required this.id,
    required this.name,
    required this.profileImageUrl,
    required this.upcomingEvents,
  });

  // Copy method to create a modified copy of the Friend
  Friend copyWith({
    String? id,
    String? name,
    String? profileImageUrl,
    int? upcomingEvents,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
    );
  }

  // Convert a Friend object into a Map object for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'upcomingEvents': upcomingEvents,
    };
  }

  // Create a Friend object from a Map object retrieved from the database
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      name: map['name'],
      profileImageUrl: map['profileImageUrl'],
      upcomingEvents: map['upcomingEvents'],
    );
  }
}
