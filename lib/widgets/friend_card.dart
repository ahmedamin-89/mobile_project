import 'package:flutter/material.dart';

class FriendCard extends StatelessWidget {
  final String name;
  final int upcomingEvents;
  final String phoneNumber;
  final String id;
  final VoidCallback onTap;

  const FriendCard({
    super.key,
    required this.name,
    required this.id,
    required this.upcomingEvents,
    required this.phoneNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              upcomingEvents > 0
                  ? 'Upcoming Events: $upcomingEvents'
                  : 'No Upcoming Events',
              style: const TextStyle(fontSize: 12.0),
            ),
            Text(
              'Phone: $phoneNumber',
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward),
        onTap: onTap,
      ),
    );
  }
}
