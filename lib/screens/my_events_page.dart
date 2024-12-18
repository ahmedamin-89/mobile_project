import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({Key? key}) : super(key: key);

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  List<Event> myEvents = [];

  @override
  void initState() {
    super.initState();
    fetchMyEvents();
  }

  Future<void> fetchMyEvents() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      final events = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromFirestore(data);
      }).toList();

      setState(() {
        myEvents = events;
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

  void navigateToAddEvent() {
    Navigator.pushNamed(context, '/event-details').then((_) {
      // Refresh the events list after adding a new event
      fetchMyEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
      ),
      body: myEvents.isEmpty
          ? const Center(child: Text('No events found.'))
          : ListView.builder(
              itemCount: myEvents.length,
              itemBuilder: (context, index) {
                final event = myEvents[index];
                return Card(
                  child: ListTile(
                    title: Text(event.name),
                    subtitle: Text(
                      '${event.date.toIso8601String().split('T')[0]} | ${event.location} | ${event.status}',
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => navigateToEventDetails(event),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddEvent,
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
      ),
    );
  }
}
