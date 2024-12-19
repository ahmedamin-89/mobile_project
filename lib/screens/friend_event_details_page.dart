import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event.dart';

class FriendEventDetailsPage extends StatefulWidget {
  final Event event;

  const FriendEventDetailsPage({super.key, required this.event});

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
    fetchUsernames();
  }

  Future<void> fetchUsernames() async {
    try {
      final userIds = requestedGifts
          .where((gift) =>
              gift['pledgedBy'] != null &&
              (gift['pledgedBy'] as String).isNotEmpty)
          .map((gift) => gift['pledgedBy'] as String)
          .toSet();

      for (var userId in userIds) {
        if (userId.isEmpty || userNames.containsKey(userId)) continue;

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          userNames[userId] = userDoc['username'] ?? 'Unknown';
        } else {
          userNames[userId] = 'Unknown';
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

      final eventRef =
          FirebaseFirestore.instance.collection('events').doc(widget.event.id);

      final eventDoc = await eventRef.get();
      if (!eventDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event not found.')),
        );
        return;
      }

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

      await eventRef.update({'requestedGifts': gifts});

      setState(() {
        requestedGifts = gifts;
        userNames[userId] = 'You';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gift "$giftName" marked as $status.')),
      );

      // Notify event owner
      final eventOwnerId = eventDoc['userId'];
      await _sendNotificationToEventOwner(eventOwnerId, giftName, status);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update gift status: $e')),
      );
    }
  }

  Future<void> _sendNotificationToEventOwner(
      String eventOwnerId, String giftName, String status) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(eventOwnerId)
        .get();
    if (!userDoc.exists) return;

    final fcmToken = userDoc['fcmToken'];
    if (fcmToken == null || fcmToken.isEmpty) return;

    final messageTitle = status == 'Pledged' ? 'Gift Pledged!' : 'Gift Bought!';
    final messageBody = 'The gift "$giftName" in your event has been $status.';

    await sendFcmMessage(fcmToken, messageTitle, messageBody);
  }

  Future<void> sendFcmMessage(String token, String title, String body) async {
    // Implement your cloud function or server logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.event.name} Gifts (${widget.event.category})'),
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
                  final pledgedById = gift['pledgedBy'] as String?;
                  final pledgedBy =
                      (pledgedById != null && pledgedById.isNotEmpty)
                          ? userNames[pledgedById] ?? 'Unknown'
                          : 'None';

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
