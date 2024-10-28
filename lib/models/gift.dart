// lib/models/gift.dart

class Gift {
  final String id;
  final String name;
  final String description;
  final String category; // e.g., electronics, books, etc.
  final double price;
  final String status; // "Available", "Pledged", "Purchased"
  final String eventId; // The ID of the associated event
  final String? imageUrl; // Optional URL for the gift image
  final String? pledgedBy; // ID of the user who pledged the gift
  final DateTime? dueDate; // Due date for the pledged gift

  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.eventId,
    this.imageUrl,
    this.pledgedBy,
    this.dueDate,
  });

  // Copy method to create a modified copy of the Gift
  Gift copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? status,
    String? eventId,
    String? imageUrl,
    String? pledgedBy,
    DateTime? dueDate,
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      imageUrl: imageUrl ?? this.imageUrl,
      pledgedBy: pledgedBy ?? this.pledgedBy,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  // Convert a Gift object into a Map object for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
      'imageUrl': imageUrl,
      'pledgedBy': pledgedBy,
      'dueDate': dueDate?.toIso8601String(),
    };
  }

  // Create a Gift object from a Map object retrieved from the database
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      eventId: map['eventId'],
      imageUrl: map['imageUrl'],
      pledgedBy: map['pledgedBy'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }

  // Getter to format the due date
  String get formattedDueDate {
    if (dueDate == null) return '';
    return 'Due: ${dueDate!.month}/${dueDate!.day}/${dueDate!.year}';
  }
}
