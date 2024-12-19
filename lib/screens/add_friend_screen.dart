import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController usernameController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  Future<void> sendFriendRequest() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        errorMessage = 'User not authenticated.';
      });
      return;
    }

    final username = usernameController.text.trim();

    if (username.isEmpty) {
      setState(() {
        errorMessage = 'Username cannot be empty.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Find the target user by username
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          errorMessage = 'User not found.';
        });
        return;
      }

      final targetUserDoc = querySnapshot.docs.first;
      final targetUserId = targetUserDoc.id;

      // Check if the user is trying to send a request to themselves
      if (targetUserId == currentUser.uid) {
        setState(() {
          errorMessage = 'You cannot send a friend request to yourself.';
        });
        return;
      }

      // Add a friend request to the target user's friendRequests subcollection
      final currentUsername = (await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get())['username'];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId)
          .collection('friendRequests')
          .add({
        'fromUserId': currentUser.uid,
        'fromUsername': currentUsername,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        errorMessage = null;
        usernameController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent successfully!')),
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to send friend request: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the username of the user you want to add as a friend:',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isLoading ? null : sendFriendRequest,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send Friend Request'),
            ),
          ],
        ),
      ),
    );
  }
}
