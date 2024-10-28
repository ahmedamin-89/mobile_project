// lib/screens/my_pledged_gifts_page.dart
import 'package:flutter/material.dart';
import '../models/gift.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  const MyPledgedGiftsPage({super.key});

  @override
  State<MyPledgedGiftsPage> createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  List<Gift> pledgedGifts = [
    // Sample data
    Gift(
      id: 'gift1',
      name: 'Bluetooth Speaker',
      description: 'Portable speaker.',
      category: 'Electronics',
      price: 49.99,
      status: 'Pledged',
      eventId: 'event1',
      pledgedBy: 'user123',
      dueDate: DateTime.now().add(const Duration(days: 5)),
    ),
    Gift(
      id: 'gift2',
      name: 'Board Game',
      description: 'Fun for the whole family.',
      category: 'Toys',
      price: 29.99,
      status: 'Pledged',
      eventId: 'event2',
      pledgedBy: 'user123',
      dueDate: DateTime.now().add(const Duration(days: 12)),
    ),
    // Add more pledged gifts
  ];

  void modifyPledge(Gift gift) {
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Modify pledge for "${gift.name}" not implemented')),
    );
  }

  void removePledge(Gift gift) {
    setState(() {
      pledgedGifts.remove(gift);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pledge for "${gift.name}" removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
      ),
      body: ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return Card(
            child: ListTile(
              title: Text(gift.name),
              subtitle: Text(
                  'Due: ${gift.formattedDueDate}\nEvent ID: ${gift.eventId}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => modifyPledge(gift),
                    tooltip: 'Modify Pledge',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => removePledge(gift),
                    tooltip: 'Remove Pledge',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
