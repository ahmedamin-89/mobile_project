import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_project/screens/auth.dart';
import 'package:mobile_project/screens/my_events_page.dart';

import 'screens/home_page.dart';
import 'screens/splash_screen.dart';
import 'models/event.dart';
import 'screens/event_details_page.dart';
import 'screens/gift_list_page.dart';
import 'screens/gift_details_page.dart';
import 'screens/profile_page.dart';
import 'screens/my_pledged_gifts_page.dart';
import 'screens/friend_event_list_page.dart';
import 'models/friend.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xffd6eadf),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            // User is logged in, show the main navigation with bottom bar
            return const MainNavigation();
          }

          return const AuthScreen();
        },
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/event-details':
            if (settings.arguments is Event) {
              final event = settings.arguments as Event;
              return MaterialPageRoute(
                builder: (_) => EventDetailsPage(event: event),
              );
            } else {
              return MaterialPageRoute(
                builder: (_) => const EventDetailsPage(),
              );
            }
          case '/friend-events':
            if (settings.arguments is Friend) {
              final friend = settings.arguments as Friend;
              return MaterialPageRoute(
                builder: (_) => FriendEventListPage(friend: friend),
              );
            }
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('No friend provided')),
              ),
            );
          case '/gifts':
            if (settings.arguments is Event) {
              final event = settings.arguments as Event;
              return MaterialPageRoute(
                builder: (_) => GiftListPage(event: event),
              );
            } else {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('No event provided')),
                ),
              );
            }
          case '/gift-details':
            return MaterialPageRoute(builder: (_) => const GiftDetailsPage());
          case '/profile':
            return MaterialPageRoute(builder: (_) => const ProfilePage());
          case '/my-pledged-gifts':
            return MaterialPageRoute(
                builder: (_) => const MyPledgedGiftsPage());
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}

/// This widget will hold the bottom navigation bar and switch between different pages.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MyEventsPage(),
    const MyPledgedGiftsPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'My Events'),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'My Gifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
