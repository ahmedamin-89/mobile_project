// lib/screens/profile_page.dart
import 'package:flutter/material.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Sample user data
  User user = User(
    id: 'user123',
    name: 'John Doe',
    email: 'john.doe@example.com',
    preferences: {'notifications': true},
  );

  void saveProfile() {
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Save Profile functionality not implemented')),
    );
  }

  void navigateToMyEvents() {
    Navigator.pushNamed(context, '/events');
  }

  void navigateToMyPledgedGifts() {
    Navigator.pushNamed(context, '/my-pledged-gifts');
  }

  @override
  Widget build(BuildContext context) {
    bool notificationsEnabled = user.preferences['notifications'] ?? true;

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
            TextField(
              decoration: const InputDecoration(labelText: 'Name'),
              controller: TextEditingController(text: user.name),
              onChanged: (value) => user = user.copyWith(name: value),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
              controller: TextEditingController(text: user.email),
              onChanged: (value) => user = user.copyWith(email: value),
            ),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  user = user.copyWith(
                    preferences: {'notifications': value},
                  );
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: saveProfile,
              child: const Text('Save Changes'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('My Events'),
              onTap: navigateToMyEvents,
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('My Pledged Gifts'),
              onTap: navigateToMyPledgedGifts,
            ),
          ],
        ),
      ),
    );
  }
}
