import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final String userId;
  final String status;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    required this.status,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'date': Timestamp.fromDate(date),
      'location': location,
      'description': description,
      'userId': userId,
      'status': status,
    };
  }

  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: data['id'],
      name: data['name'],
      date: (data['date'] as Timestamp).toDate(),
      location: data['location'],
      description: data['description'],
      userId: data['userId'],
      status: data['status'],
    );
  }
}
