import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({Key? key}) : super(key: key);

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  List<Event> events = [];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('events').get();
      final fetchedEvents =
          querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();

      setState(() {
        events = fetchedEvents;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading events: $e')),
      );
    }
  }

  void addEvent() {
    Navigator.pushNamed(context, '/event-details').then((value) {
      if (value == true) {
        fetchEvents(); // Refresh events after adding
      }
    });
  }

  void editEvent(Event event) {
    Navigator.pushNamed(context, '/event-details', arguments: event)
        .then((value) {
      if (value == true) {
        fetchEvents(); // Refresh events after editing
      }
    });
  }

  Future<void> deleteEvent(Event event) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .delete();
      setState(() {
        events.remove(event);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event "${event.name}" deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
      ),
      body: events.isEmpty
          ? const Center(
              child: Text('No events available. Add an event to get started!'),
            )
          : ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  child: ListTile(
                    title: Text(event.name),
                    subtitle: Text(
                        '${event.date.toLocal()} | ${event.location} | ${event.status}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => editEvent(event),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteEvent(event),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addEvent,
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
    );
  }
}
