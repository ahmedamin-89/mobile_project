import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/friend.dart';
import 'friend_event_details_page.dart';

class FriendEventListPage extends StatefulWidget {
  final Friend friend;

  const FriendEventListPage({super.key, required this.friend});

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
    setState(() {
      isLoading = true;
    });

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

  Future<void> _handleRefresh() async {
    await fetchFriendEvents();
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
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: friendEvents.isEmpty
                      ? const Center(
                          child: Text('No events found for this friend.'),
                        )
                      : ListView.builder(
                          itemCount: friendEvents.length,
                          itemBuilder: (context, index) {
                            final event = friendEvents[index];
                            return Card(
                              child: ListTile(
                                title: Text(event.name),
                                subtitle: Text(
                                  '${event.date.toIso8601String().split('T')[0]} | ${event.location} | ${event.status} | ${event.category}',
                                ),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () => navigateToEventDetails(event),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
