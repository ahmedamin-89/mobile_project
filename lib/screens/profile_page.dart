import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../widgets/friend_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool notificationsEnabled = true;
  bool isLoading = true;
  List<Friend> friends = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadFriends();
  }

  Future<void> _loadUserProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _usernameController.text = data['username'] ?? '';
          notificationsEnabled = data['preferences']?['notifications'] ?? true;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false; // Stop loading if user document doesn't exist
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  Future<void> _loadFriends() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('friends')
          .where('ownerId', isEqualTo: userId)
          .get();

      final fetchedFriends = querySnapshot.docs
          .map(
              (doc) => Friend.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        friends = fetchedFriends;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading friends: $e')),
      );
    }
  }

  Future<void> _saveProfile() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    try {
      // Validate the username to ensure it's unique
      final username = _usernameController.text.trim();
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (existingUser.docs.isNotEmpty &&
          existingUser.docs.first.id != userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username is already taken')),
        );
        return;
      }

      final updatedData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'username': username,
        'preferences': {'notifications': notificationsEnabled},
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(updatedData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  void navigateToMyEvents() {
    Navigator.pushNamed(context, '/events');
  }

  void navigateToFriendRequests() {
    Navigator.pushNamed(context, '/friend-requests');
  }

  void navigateToFriendDetails(Friend friend) {
    Navigator.pushNamed(context, '/friend-events', arguments: friend);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            // Name Field
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              controller: _nameController,
            ),
            // Email Field (Read-only)
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              controller: _emailController,
              readOnly: true,
            ),
            // Username Field
            TextField(
              decoration: const InputDecoration(labelText: 'Username'),
              controller: _usernameController,
            ),
            // Notifications Toggle
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Changes'),
            ),
            const Divider(),
            // Navigation to My Events
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('My Events'),
              onTap: navigateToMyEvents,
            ),
            // Navigation to My Pledged Gifts
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Friend Requests'),
              onTap: navigateToFriendRequests,
            ),
          ],
        ),
      ),
    );
  }
}
