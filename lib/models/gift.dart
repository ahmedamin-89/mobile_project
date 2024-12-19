class Gift {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final String eventId;
  final String? imageUrl;
  final String? pledgedBy;
  final DateTime? dueDate;

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

  Map<String, dynamic> toFirestore() {
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

  factory Gift.fromFirestore(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num).toDouble(),
      status: map['status'] ?? 'Available',
      eventId: map['eventId'],
      imageUrl: map['imageUrl'],
      pledgedBy: map['pledgedBy'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    );
  }

  String get formattedDueDate {
    if (dueDate == null) return '';
    return 'Due: ${dueDate!.month}/${dueDate!.day}/${dueDate!.year}';
  }
}
