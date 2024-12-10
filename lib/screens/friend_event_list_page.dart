import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/friend.dart';

class FriendEventListPage extends StatefulWidget {
  final Friend friend;

  const FriendEventListPage({Key? key, required this.friend}) : super(key: key);

  @override
  State<FriendEventListPage> createState() => _FriendEventListPageState();
}

class _FriendEventListPageState extends State<FriendEventListPage> {
  List<Event> friendEvents = [];

  @override
  void initState() {
    super.initState();
    fetchFriendEvents();
  }

  Future<void> fetchFriendEvents() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: widget.friend.id)
          .get();

      final events = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromFirestore(data);
      }).toList();

      setState(() {
        friendEvents = events;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading events: $e')),
      );
    }
  }

  void navigateToEventDetails(Event event) {
    Navigator.pushNamed(context, '/event-details', arguments: event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.friend.name}\'s Events'),
      ),
      body: friendEvents.isEmpty
          ? const Center(child: Text('No events found for this friend.'))
          : ListView.builder(
              itemCount: friendEvents.length,
              itemBuilder: (context, index) {
                final event = friendEvents[index];
                return Card(
                  child: ListTile(
                    title: Text(event.name),
                    subtitle: Text(
                      '${event.date.toLocal()} | ${event.location} | ${event.status}',
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => navigateToEventDetails(event),
                  ),
                );
              },
            ),
    );
  }
}
