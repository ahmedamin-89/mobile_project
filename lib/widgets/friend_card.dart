import 'package:flutter/material.dart';
import '../models/friend.dart';

class FriendCard extends StatelessWidget {
  final String name;
  final int upcomingEvents;
  final String phoneNumber;
  final String id;
  final VoidCallback onTap;

  const FriendCard({
    Key? key,
    required this.name,
    required this.id,
    required this.upcomingEvents,
    required this.phoneNumber,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child:
            Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimary),
      ),
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(upcomingEvents > 0
              ? 'Upcoming Events: $upcomingEvents'
              : 'No Upcoming Events'),
          Text('Phone: $phoneNumber'),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }
}
