import 'package:flutter/material.dart';

class FriendCard extends StatelessWidget {
  final String name;
  final String profileImageUrl;
  final int upcomingEvents;
  final String phoneNumber;
  final VoidCallback onTap;

  const FriendCard({
    Key? key,
    required this.name,
    required this.profileImageUrl,
    required this.upcomingEvents,
    required this.phoneNumber,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
        child: profileImageUrl.isEmpty ? const Icon(Icons.person) : null,
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
