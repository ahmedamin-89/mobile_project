import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend.dart';
import '../widgets/friend_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Friend> friends = [];
  List<Friend> filteredFriends = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('friends').get();
      final List<Friend> fetchedFriends = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Friend.fromFirestore(data);
      }).toList();

      setState(() {
        friends = fetchedFriends;
        filteredFriends = fetchedFriends;
      });
    } catch (e) {
      print('Error fetching friends: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load friends: $e')),
      );
    }
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredFriends = friends.where((friend) {
        return friend.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    });
  }

  void navigateToFriendGiftList(Friend friend) {
    Navigator.pushNamed(
      context,
      '/gifts',
      arguments: {'friend': friend},
    );
  }

  Future<void> addFriend() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController profileUrlController = TextEditingController();
    final TextEditingController eventsController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Friend'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: profileUrlController,
                  decoration:
                      const InputDecoration(labelText: 'Profile Image URL'),
                ),
                TextField(
                  controller: eventsController,
                  decoration:
                      const InputDecoration(labelText: 'Upcoming Events'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Cancel
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirm
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // Validate inputs
      if (nameController.text.trim().isEmpty ||
          phoneNumberController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Name and phone number are required fields!')),
        );
        return;
      }

      try {
        final newFriend = Friend(
          id: FirebaseFirestore.instance.collection('friends').doc().id,
          name: nameController.text.trim(),
          profileImageUrl: profileUrlController.text.trim(),
          upcomingEvents: int.tryParse(eventsController.text.trim()) ?? 0,
          phoneNumber: phoneNumberController.text.trim(),
        );

        // Save the new friend to Firestore
        await FirebaseFirestore.instance
            .collection('friends')
            .doc(newFriend.id)
            .set(newFriend.toFirestore());

        // Update local state
        setState(() {
          friends.add(newFriend);
          filteredFriends.add(newFriend);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Friend "${newFriend.name}" added successfully!')),
        );
      } catch (e) {
        print('Error adding friend: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add friend: $e')),
        );
      }
    }
  }

  void createEventOrList() {
    Navigator.pushNamed(context, '/event-details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedieaty'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: addFriend,
            tooltip: 'Add Friend',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {}, // Placeholder for a full-screen search UI
          ),
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search Friends',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: updateSearch,
            ),
          ),
          // Friend List
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredFriends[index];
                return FriendCard(
                  name: friend.name,
                  profileImageUrl: friend.profileImageUrl,
                  upcomingEvents: friend.upcomingEvents,
                  phoneNumber: friend.phoneNumber,
                  onTap: () => navigateToFriendGiftList(friend),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: createEventOrList,
        icon: const Icon(Icons.add),
        label: const Text('Create Your Own Event/List'),
      ),
    );
  }
}
