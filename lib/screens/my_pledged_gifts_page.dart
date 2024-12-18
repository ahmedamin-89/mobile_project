import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/gift.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  const MyPledgedGiftsPage({Key? key}) : super(key: key);

  @override
  State<MyPledgedGiftsPage> createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  List<Gift> pledgedGifts = [];
  // These maps will store additional info for quick lookup
  Map<String, String> eventNames = {}; // eventId -> eventName
  Map<String, String> eventOwners = {}; // eventId -> eventOwnerId
  Map<String, String> ownerUsernames = {}; // userId -> username

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPledgedGifts();
  }

  Future<void> fetchPledgedGifts() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          errorMessage = 'User not authenticated.';
          isLoading = false;
        });
        return;
      }

      final eventsSnapshot =
          await FirebaseFirestore.instance.collection('events').get();

      final List<Gift> tempGifts = [];
      final Set<String> ownerIdsToFetch = {};

      for (var eventDoc in eventsSnapshot.docs) {
        final eventData = eventDoc.data();
        final requestedGifts = eventData['requestedGifts'] as List<dynamic>?;

        if (requestedGifts == null) continue;

        final eventId = eventDoc.id;
        final eventName = eventData['name'] ?? 'Unnamed Event';
        final eventOwnerId = eventData['userId'] ?? '';

        eventNames[eventId] = eventName;
        eventOwners[eventId] = eventOwnerId;

        // We will fetch owner usernames after we know all eventOwnerIds
        if (eventOwnerId.isNotEmpty) {
          ownerIdsToFetch.add(eventOwnerId);
        }

        // Filter gifts pledged by current user
        for (var g in requestedGifts) {
          final giftName = g['giftName'] as String?;
          final pledgedBy = g['pledgedBy'] as String?;
          final status = g['status'] as String?;

          // Only add if pledgedBy matches current user
          if (pledgedBy == currentUser.uid) {
            final gift = Gift(
              id: '$eventId-$giftName',
              name: giftName ?? 'Unknown Gift',
              description: '',
              category: '',
              price: 0.0,
              status: status ?? 'Pledged',
              eventId: eventId,
              imageUrl: null,
              pledgedBy: pledgedBy,
              dueDate: null,
            );
            tempGifts.add(gift);
          }
        }
      }

      // Fetch usernames for all event owners
      if (ownerIdsToFetch.isNotEmpty) {
        final usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: ownerIdsToFetch.toList())
            .get();

        for (var userDoc in usersSnapshot.docs) {
          final data = userDoc.data();
          final username = data['username'] ?? 'Unknown User';
          ownerUsernames[userDoc.id] = username;
        }
      }

      setState(() {
        pledgedGifts = tempGifts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading pledged gifts: $e';
        isLoading = false;
      });
    }
  }

  void modifyPledge(Gift gift) {
    // Implement modify pledge functionality if needed
  }

  Future<void> removePledge(Gift gift) async {
    try {
      // To remove a pledge, update the event's requestedGifts array:
      final eventRef =
          FirebaseFirestore.instance.collection('events').doc(gift.eventId);
      final eventDoc = await eventRef.get();

      if (!eventDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event not found.')),
        );
        return;
      }

      final eventData = eventDoc.data();
      if (eventData == null || eventData['requestedGifts'] == null) {
        return;
      }

      List<dynamic> requestedGifts =
          List<dynamic>.from(eventData['requestedGifts']);

      // Find the gift in requestedGifts
      final giftIndex = requestedGifts.indexWhere((g) =>
          g['giftName'] == gift.name && g['pledgedBy'] == gift.pledgedBy);
      if (giftIndex == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gift not found in event.')),
        );
        return;
      }

      // Update the gift's status to "Available" and pledgedBy = ""
      requestedGifts[giftIndex] = {
        'giftName': gift.name,
        'status': 'Available',
        'pledgedBy': '',
      };

      await eventRef.update({
        'requestedGifts': requestedGifts,
      });

      setState(() {
        pledgedGifts.remove(gift);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pledge for "${gift.name}" removed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove pledge: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }

    if (pledgedGifts.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No pledged gifts found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
      ),
      body: ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          final eventId = gift.eventId;
          final eventName = eventNames[eventId] ?? eventId;
          final eventOwnerId = eventOwners[eventId] ?? '';
          final ownerUsername = ownerUsernames[eventOwnerId] ?? 'Unknown User';

          return Card(
            child: ListTile(
              title: Text(gift.name),
              subtitle: Text(
                'Event: $eventName\nOwner: $ownerUsername\nStatus: ${gift.status}',
              ),
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
