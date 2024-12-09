// lib/screens/event_list_page.dart
import 'package:flutter/material.dart';
import '../widgets/event_card.dart';
import '../models/event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [
    // Sample data
    Event(
      id: 'event1',
      name: 'Birthday Party',
      date: DateTime.now().add(const Duration(days: 10)),
      location: 'My House',
      description: 'A fun birthday party.',
      userId: 'user1',
      status: 'Upcoming',
    ),
    Event(
      id: 'event2',
      name: 'Graduation',
      date: DateTime.now().subtract(const Duration(days: 30)),
      location: 'University Hall',
      description: 'Graduation ceremony.',
      userId: 'user1',
      status: 'Past',
    ),
    // Add more events
  ];

  String sortBy = 'name';

  void sortEvents(String criterion) {
    setState(() {
      sortBy = criterion;
      if (criterion == 'name') {
        events.sort((a, b) => a.name.compareTo(b.name));
      } else if (criterion == 'status') {
        events.sort((a, b) => a.status.compareTo(b.status));
      } else if (criterion == 'date') {
        events.sort((a, b) => a.date.compareTo(b.date));
      }
    });
  }

  void navigateToGiftList(Event event) {
    Navigator.pushNamed(
      context,
      '/gifts',
      arguments: {'event': event},
    );
  }

  void addEvent() {
    Navigator.pushNamed(context, '/event-details');
  }

  void editEvent(Event event) {
    Navigator.pushNamed(
      context,
      '/event-details',
      arguments: event,
    );
  }

  void deleteEvent(Event event) {
    setState(() {
      events.remove(event);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event "${event.name}" deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        actions: [
          PopupMenuButton<String>(
            onSelected: sortEvents,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(
                  value: 'status', child: Text('Sort by Status')),
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No events found.'));
          }
          final events = snapshot.data!.docs
              .map((doc) => Event.fromFirestore(doc))
              .toList();
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                eventName: event.name,
                eventDate: event.date,
                eventStatus: event.status,
                onTap: () => navigateToGiftList(event),
                onEdit: () => editEvent(event),
                onDelete: () => deleteEvent(event),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addEvent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
