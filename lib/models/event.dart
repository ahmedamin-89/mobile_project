import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final String userId;
  final String status;
  final List<String> requestedGifts;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    required this.status,
    required this.requestedGifts,
  });

  factory Event.fromFirestore(Map<String, dynamic> data) {
    return Event(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      date:
          (data['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      userId: data['userId'] ?? '',
      status: data['status'] ?? '',
      requestedGifts: List<String>.from(
          data['requestedGifts'] ?? []), // Handle list of gifts
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'date': Timestamp.fromDate(date), // Convert DateTime to Timestamp
      'location': location,
      'description': description,
      'userId': userId,
      'status': status,
      'requestedGifts': requestedGifts, // Save list of gifts
    };
  }
}
