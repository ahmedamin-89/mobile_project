// lib/app.dart
import 'package:flutter/material.dart';
import 'package:mobile_project/screens/event_details_page.dart';
import 'screens/home_page.dart';
import 'screens/event_list_page.dart';
import 'screens/gift_list_page.dart';
import 'screens/gift_details_page.dart';
import 'screens/profile_page.dart';
import 'screens/my_pledged_gifts_page.dart';
import 'models/event.dart';

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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomePage());
          case '/events':
            return MaterialPageRoute(builder: (_) => const EventListPage());
          // In app.dart, inside onGenerateRoute:
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
