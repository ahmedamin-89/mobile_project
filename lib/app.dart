import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile_project/screens/auth.dart';

import 'screens/home_page.dart';
import 'screens/splash_screen.dart';
import 'models/event.dart';
import 'screens/event_details_page.dart';
import 'screens/gift_list_page.dart';
import 'screens/gift_details_page.dart';
import 'screens/profile_page.dart';
import 'screens/my_pledged_gifts_page.dart';

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
            return const SplashScreen(); // Show splash screen while loading
          }

          if (snapshot.hasData) {
            return const HomePage(); // User is logged in, show the home page
          }

          // Show LoginPage or RegisterPage based on a condition (e.g., a toggle or user choice)
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
