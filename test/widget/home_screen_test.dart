import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/core/localization/greek_strings.dart';
import 'package:pantomima/features/home/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets(
      'Renders all Greek titles, tagline, cards, and offline notice',
      (tester) async {
        bool teamGameTapped = false;
        bool freePlayTapped = false;
        bool settingsTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: HomeScreen(
              isLoading: false,
              onRetry: () {},
              onStartTeamGame: () => teamGameTapped = true,
              onStartFreePlay: () => freePlayTapped = true,
              onOpenSettings: () => settingsTapped = true,
            ),
          ),
        );

        // Verify app title
        expect(find.text(GreekStrings.appTitle), findsOneWidget);

        // Verify tagline
        expect(find.text(GreekStrings.appTagline), findsOneWidget);

        // Verify menu buttons
        expect(find.text(GreekStrings.teamGame), findsOneWidget);
        expect(find.text(GreekStrings.freePlay), findsOneWidget);

        // Verify offline notice
        expect(find.text(GreekStrings.offlineNotice), findsOneWidget);

        // Tap Team Game
        await tester.tap(find.text(GreekStrings.teamGame));
        expect(teamGameTapped, isTrue);

        // Tap Free Play
        await tester.tap(find.text(GreekStrings.freePlay));
        expect(freePlayTapped, isTrue);

        // Tap Settings
        await tester.tap(find.byIcon(Icons.settings_outlined));
        expect(settingsTapped, isTrue);
      },
    );

    testWidgets('Renders loading screen when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            isLoading: true,
            onRetry: () {},
            onStartTeamGame: () {},
            onStartFreePlay: () {},
            onOpenSettings: () {},
          ),
        ),
      );

      expect(find.text(GreekStrings.loading), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'Renders error screen with retry button when errorMessage is present',
      (tester) async {
        bool retryTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: HomeScreen(
              isLoading: false,
              errorMessage: 'Σφάλμα ανάγνωσης αρχείου',
              onRetry: () => retryTapped = true,
              onStartTeamGame: () {},
              onStartFreePlay: () {},
              onOpenSettings: () {},
            ),
          ),
        );

        expect(find.text('Σφάλμα ανάγνωσης αρχείου'), findsOneWidget);
        expect(find.text(GreekStrings.retry), findsOneWidget);

        await tester.tap(find.text(GreekStrings.retry));
        expect(retryTapped, isTrue);
      },
    );
  });
}
