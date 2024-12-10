import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/screens/friend_event_details_page.dart';
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
  bool isLoading = true;
  String? errorMessage;

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

      final events = querySnapshot.docs
          .map((doc) => Event.fromFirestore(doc.data()))
          .toList();

      setState(() {
        friendEvents = events;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading events: $e';
        isLoading = false;
      });
    }
  }

  void navigateToEventDetails(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendEventDetailsPage(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.friend.name}\'s Events'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : friendEvents.isEmpty
                  ? const Center(
                      child: Text('No events found for this friend.'))
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
