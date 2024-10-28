// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import '../widgets/friend_card.dart';
import '../models/friend.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Friend> friends = [
    // Sample data
    Friend(
      id: 'friend1',
      name: 'Alice Johnson',
      profileImageUrl: '',
      upcomingEvents: 2,
    ),
    Friend(
      id: 'friend2',
      name: 'Bob Smith',
      profileImageUrl: '',
      upcomingEvents: 1,
    ),
    Friend(
      id: 'friend3',
      name: 'Carol Williams',
      profileImageUrl: '',
      upcomingEvents: 0,
    ),
  ];

  List<Friend> filteredFriends = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredFriends = friends;
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

  void addFriend() {
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Friend functionality not implemented')),
    );
  }

  void createEventOrList() {
    Navigator.pushNamed(context, '/events');
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
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              onChanged: updateSearch,
              hintText: 'Search Friends...',
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredFriends[index];
                return FriendCard(
                  name: friend.name,
                  profileImageUrl: friend.profileImageUrl,
                  upcomingEvents: friend.upcomingEvents,
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
