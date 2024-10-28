// lib/models/event.dart

class Event {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final String userId; // The ID of the user who created the event
  final String status; // "Upcoming", "Current", or "Past"

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    required this.status,
  });

  // Copy method to create a modified copy of the Event
  Event copyWith({
    String? id,
    String? name,
    DateTime? date,
    String? location,
    String? description,
    String? userId,
    String? status,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      status: status ?? this.status,
    );
  }

  // Convert an Event object into a Map object for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'userId': userId,
      'status': status,
    };
  }

  // Create an Event object from a Map object retrieved from the database
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      description: map['description'],
      userId: map['userId'],
      status: map['status'],
    );
  }

  // Determine the event's status based on the current date
  String get computedStatus {
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'Upcoming';
    } else if (date.isBefore(now)) {
      return 'Past';
    } else {
      return 'Current';
    }
  }
}
