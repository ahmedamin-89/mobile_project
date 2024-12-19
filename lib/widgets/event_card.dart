// lib/widgets/event_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final String eventName;
  final DateTime eventDate;
  final String eventStatus; // "Upcoming", "Current", "Past"
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EventCard({
    super.key,
    required this.eventName,
    required this.eventDate,
    required this.eventStatus,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String get formattedDate {
    return DateFormat.yMMMd().format(eventDate);
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (eventStatus.toLowerCase()) {
      case 'upcoming':
        statusColor = Colors.green;
        break;
      case 'current':
        statusColor = Colors.blue;
        break;
      case 'past':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.black;
    }

    return Card(
      child: ListTile(
        title: Text(eventName),
        subtitle: Text('Date: $formattedDate'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              eventStatus,
              style: TextStyle(color: statusColor),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit Event',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              tooltip: 'Delete Event',
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
