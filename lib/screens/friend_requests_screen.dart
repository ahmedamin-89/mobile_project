import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({Key? key}) : super(key: key);

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  Future<void> acceptRequest(String requestId, String fromUserId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();

      // Add the sender to the current user's friends list
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(currentUser.uid),
        {
          'friends': FieldValue.arrayUnion([fromUserId]),
        },
      );

      // Add the current user to the sender's friends list
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(fromUserId),
        {
          'friends': FieldValue.arrayUnion([currentUser.uid]),
        },
      );

      // Delete the friend request
      batch.delete(
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('friendRequests')
            .doc(requestId),
      );

      await batch.commit();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept request: $e')),
      );
    }
  }

  Future<void> rejectRequest(String requestId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('friendRequests')
          .doc(requestId)
          .delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Center(child: Text('User not authenticated.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('friendRequests')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text('No friend requests.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final fromUsername = request['fromUsername'];
              final fromUserId = request['fromUserId'];

              return ListTile(
                title: Text('Request from $fromUsername'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => acceptRequest(request.id, fromUserId),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => rejectRequest(request.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
