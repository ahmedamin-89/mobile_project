import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';

class EventDetailsPage extends StatefulWidget {
  final Event? event;

  const EventDetailsPage({super.key, this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  late String name;
  late DateTime date;
  late String location;
  late String description;
  late List<Map<String, dynamic>> requestedGifts;
  String category = 'Other';

  final List<String> eventCategories = [
    'Birthday',
    'Wedding',
    'Anniversary',
    'Holiday',
    'Baby Shower',
    'Graduation',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      name = widget.event!.name;
      date = widget.event!.date;
      location = widget.event!.location;
      description = widget.event!.description;
      requestedGifts = widget.event!.requestedGifts;
      category =
          widget.event!.category.isNotEmpty ? widget.event!.category : 'Other';
      _dateController.text = '${date.toLocal()}'.split(' ')[0];
    } else {
      name = '';
      date = DateTime.now();
      location = '';
      description = '';
      requestedGifts = [];
      category = 'Other';
      _dateController.text = '${date.toLocal()}'.split(' ')[0];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != date) {
      setState(() {
        date = picked;
        _dateController.text = '${date.toLocal()}'.split(' ')[0];
      });
    }
  }

  void saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

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
      userId: userId,
      status: status,
      requestedGifts: requestedGifts,
      category: category,
    );

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(newEvent.id)
          .set(newEvent.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event "${newEvent.name}" saved')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save event: $e')),
      );
    }
  }

  Future<void> _addGiftDialog(BuildContext context) async {
    final TextEditingController giftController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Gift'),
          content: TextField(
            controller: giftController,
            decoration: const InputDecoration(labelText: 'Gift Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == true && giftController.text.isNotEmpty) {
      setState(() {
        requestedGifts.add({
          'giftName': giftController.text,
          'status': 'Not Selected',
          'pledgedBy': ''
        });
      });
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
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter an event name' : null,
                onSaved: (value) => name = value!,
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Event Date'),
                    controller: _dateController,
                  ),
                ),
              ),
              TextFormField(
                initialValue: location,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a location' : null,
                onSaved: (value) => location = value!,
              ),
              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => description = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: eventCategories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => category = value!),
              ),
              const SizedBox(height: 16),
              const Text('Requested Gifts'),
              const SizedBox(height: 8),
              ...requestedGifts.map((gift) => ListTile(
                    title: Text(gift['giftName']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          requestedGifts.remove(gift);
                        });
                      },
                    ),
                  )),
              ElevatedButton.icon(
                onPressed: () => _addGiftDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Gift'),
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
