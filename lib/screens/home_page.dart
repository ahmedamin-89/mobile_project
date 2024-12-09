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
      final fetchedFriends = querySnapshot.docs
          .map(
              (doc) => Friend.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        friends = fetchedFriends;
        filteredFriends = fetchedFriends;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading friends: $e')),
      );
    }
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
      filteredFriends = friends
          .where((friend) =>
              friend.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    });
  }

  void navigateToFriendGiftList(Friend friend) {
    Navigator.pushNamed(context, '/gifts', arguments: {'friend': friend});
  }

  Future<void> addFriend() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController profileUrlController = TextEditingController();
    final TextEditingController eventsController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
                decoration: const InputDecoration(labelText: 'Upcoming Events'),
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true) {
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
          upcomingEvents: int.tryParse(eventsController.text.trim()) ?? 0,
          phoneNumber: phoneNumberController.text.trim(),
        );

        await FirebaseFirestore.instance
            .collection('friends')
            .doc(newFriend.id)
            .set(newFriend.toFirestore());

        setState(() {
          friends.add(newFriend);
          filteredFriends.add(newFriend);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend "${newFriend.name}" added!')),
        );
      } catch (e) {
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
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
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
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredFriends[index];
                return FriendCard(
                  name: friend.name,
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
        label: const Text('Create Event/List'),
      ),
    );
  }
}
