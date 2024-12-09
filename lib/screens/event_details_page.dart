// lib/screens/event_details_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';

class EventDetailsPage extends StatefulWidget {
  final Event? event;

  const EventDetailsPage({Key? key, this.event}) : super(key: key);

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late DateTime date;
  late String location;
  late String description;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      // Editing an existing event
      name = widget.event!.name;
      date = widget.event!.date;
      location = widget.event!.location;
      description = widget.event!.description;
    } else {
      // Adding a new event
      name = '';
      date = DateTime.now();
      location = '';
      description = '';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
      });
    }
  }

  void saveEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String status;
      final now = DateTime.now();
      if (date.isAfter(now)) {
        status = 'Upcoming';
      } else if (date.isBefore(now)) {
        status = 'Past';
      } else {
        status = 'Current';
      }

      Event newEvent = Event(
        id: widget.event?.id ??
            FirebaseFirestore.instance.collection('events').doc().id,
        name: name,
        date: date,
        location: location,
        description: description,
        userId: 'user1', // Replace with actual user ID
        status: status,
      );

      await FirebaseFirestore.instance
          .collection('events')
          .doc(newEvent.id)
          .set(newEvent.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event "${newEvent.name}" saved')),
      );

      Navigator.pushReplacementNamed(context, '/gifts',
          arguments: {'event': newEvent});
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Event Name
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an event name' : null,
                onSaved: (value) => name = value!,
              ),
              // Event Date
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Event Date'),
                    controller: TextEditingController(
                      text: '${date.toLocal()}'.split(' ')[0],
                    ),
                  ),
                ),
              ),
              // Event Location
              TextFormField(
                initialValue: location,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a location' : null,
                onSaved: (value) => location = value!,
              ),
              // Event Description
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => description = value!,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: saveEvent,
                child: Text(isEditing ? 'Update Event' : 'Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
