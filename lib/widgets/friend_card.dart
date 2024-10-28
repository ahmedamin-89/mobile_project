// lib/widgets/friend_card.dart
import 'package:flutter/material.dart';

class FriendCard extends StatelessWidget {
  final String name;
  final String profileImageUrl;
  final int upcomingEvents;
  final VoidCallback onTap;

  const FriendCard({
    Key? key,
    required this.name,
    required this.profileImageUrl,
    required this.upcomingEvents,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
        child: profileImageUrl.isEmpty ? Icon(Icons.person) : null,
      ),
      title: Text(name),
      subtitle: Text(
        upcomingEvents > 0
            ? 'Upcoming Events: $upcomingEvents'
            : 'No Upcoming Events',
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
