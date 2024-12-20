import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login and Tap on Friend Test', () {
    testWidgets('Login with adamosman@test.com and tap on friend ahmedrashwan',
        (WidgetTester tester) async {
      // Launch the app
      app.main();

      // Wait for Firebase initialization and UI to settle
      await tester.pumpAndSettle();

      // Ensure we start from a logged-out state
      await FirebaseAuth.instance.signOut();

      // Now give time for the UI to reflect the logged-out state and show the login screen
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Find login fields
      final emailField = find.byKey(const Key('emailTextField'));
      final passwordField = find.byKey(const Key('passwordTextField'));
      final loginButton = find.byKey(const Key('loginButton'));

      expect(emailField, findsOneWidget, reason: 'Email TextField not found.');
      expect(passwordField, findsOneWidget,
          reason: 'Password TextField not found.');
      expect(loginButton, findsOneWidget, reason: 'Login button not found.');

      // Enter credentials
      await tester.enterText(emailField, 'adamosman@test.com');
      await tester.enterText(passwordField, 'a100amin');

      // Tap the login button
      await tester.tap(loginButton);

      // Wait for login process and navigation
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Wait for friend list to load
      bool listFound = false;
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.text('No friends found.').evaluate().isEmpty &&
            find.byType(ListView).evaluate().isNotEmpty) {
          listFound = true;
          break;
        }
      }
      expect(listFound, isTrue, reason: 'Friend list did not load in time.');

      // Find and tap on friend "ahmedrashwan" using the key or text
      final friendFinder = find.byKey(const Key('ahmedrashwan'));
      await tester.tap(friendFinder);

      // Wait for navigation
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // Verify navigation
      expect(find.text("ahmedrashwan's Events"), findsOneWidget,
          reason: 'Did not navigate to ahmedrashwan\'s event list page.');

      final eventTest = find.text('test');
      expect(eventTest, findsOneWidget, reason: 'Event "test" not found.');

      // Tap on the event "test"
      await tester.tap(eventTest);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      final eventSettingsbutton = find.byKey(const Key('gift_action'));
      await tester.tap(eventSettingsbutton);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      final giftPledgeButton = find.text('Pledge Gift');
      expect(giftPledgeButton, findsOneWidget,
          reason: 'Pledge Gift button not found.');

      await tester.tap(giftPledgeButton);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.pop();
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      navigator.pop();
      await tester.pump();
    });
  });
}
