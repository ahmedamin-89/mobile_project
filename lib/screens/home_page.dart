import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_project/screens/add_friend_screen.dart';
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
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("User not authenticated");
      }

      // Fetch the current user's document
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists || !userDoc.data()!.containsKey('friends')) {
        setState(() {
          friends = [];
          filteredFriends = [];
        });
        return;
      }

      // Get the list of friend IDs
      final List<String> friendIds = List<String>.from(userDoc['friends']);

      if (friendIds.isEmpty) {
        setState(() {
          friends = [];
          filteredFriends = [];
        });
        return;
      }

      // Fetch the friend details
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      final fetchedFriends = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Friend(
          id: doc.id,
          name: data['username'] ?? 'Unknown',
          numberOfEvents: data['numberOfEvents'] ?? 0,
          email: data['email'] ?? 'Not Provided',
        );
      }).toList();

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

  void navigateToAddFriendScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddFriendScreen()),
    ).then((_) => fetchFriends()); // Refresh the list after adding a friend
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hedieaty'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: navigateToAddFriendScreen,
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
            child: friends.isEmpty
                ? const Center(child: Text('No friends found.'))
                : ListView.builder(
                    itemCount: filteredFriends.length,
                    itemBuilder: (context, index) {
                      final friend = filteredFriends[index];
                      return FriendCard(
                        id: friend.id,
                        username: friend.name,
                        email: friend.email,
                        numberOfEvents: friend.numberOfEvents,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/friend-events',
                            arguments: friend,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
