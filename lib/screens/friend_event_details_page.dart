import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';

class FriendEventDetailsPage extends StatefulWidget {
  final Event event;

  const FriendEventDetailsPage({Key? key, required this.event})
      : super(key: key);

  @override
  State<FriendEventDetailsPage> createState() => _FriendEventDetailsPageState();
}

class _FriendEventDetailsPageState extends State<FriendEventDetailsPage> {
  late List<Map<String, dynamic>> requestedGifts; // Array of gift objects
  Map<String, String> userNames = {}; // Map to store userId -> username

  @override
  void initState() {
    super.initState();
    requestedGifts = widget.event.requestedGifts;
    fetchUsernames(); // Pre-fetch usernames for pledges
  }

  Future<void> fetchUsernames() async {
    try {
      final userIds = requestedGifts
          .where((gift) => gift['pledgedBy'] != null)
          .map((gift) => gift['pledgedBy'])
          .toSet();

      for (var userId in userIds) {
        if (userId == null || userNames.containsKey(userId)) continue;

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          userNames[userId] = userDoc['username'] ?? 'Unknown';
        }
      }

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch usernames: $e')),
      );
    }
  }

  Future<void> updateGiftStatus(String giftName, String status) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated.')),
        );
        return;
      }

      // Reference the event in Firestore
      final eventRef =
          FirebaseFirestore.instance.collection('events').doc(widget.event.id);

      final eventDoc = await eventRef.get();
      if (!eventDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event not found.')),
        );
        return;
      }

      // Update the requestedGifts array
      final gifts =
          List<Map<String, dynamic>>.from(eventDoc['requestedGifts'] ?? []);
      final giftIndex =
          gifts.indexWhere((gift) => gift['giftName'] == giftName);

      if (giftIndex != -1) {
        gifts[giftIndex] = {
          'giftName': giftName,
          'status': status,
          'pledgedBy': userId,
        };
      } else {
        gifts.add({
          'giftName': giftName,
          'status': status,
          'pledgedBy': userId,
        });
      }

      // Save updated gifts back to Firestore
      await eventRef.update({'requestedGifts': gifts});

      setState(() {
        requestedGifts = gifts;
        userNames[userId] = 'You'; // Optionally store the current user
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift "$giftName" marked as $status.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update gift status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.event.name} Gifts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: requestedGifts.isEmpty
            ? const Center(child: Text('No requested gifts for this event.'))
            : ListView.builder(
                itemCount: requestedGifts.length,
                itemBuilder: (context, index) {
                  final gift = requestedGifts[index];
                  final giftName = gift['giftName'];
                  final status = gift['status'] ?? 'Not Selected';
                  final pledgedById = gift['pledgedBy'];
                  final pledgedBy = userNames[pledgedById] ?? 'Unknown';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: Text(giftName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: $status'),
                          Text('Pledged by: $pledgedBy'),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) =>
                            updateGiftStatus(giftName, value),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'Pledged',
                            child: Text('Pledge Gift'),
                          ),
                          const PopupMenuItem(
                            value: 'Bought',
                            child: Text('Mark as Bought'),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
