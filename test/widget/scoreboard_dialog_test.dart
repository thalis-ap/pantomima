import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pantomima/data/models/team.dart';
import 'package:pantomima/features/scoreboard/scoreboard_dialog.dart';

void main() {
  group('ScoreboardDialog Widget Tests', () {
    testWidgets('Displays leader with colon for normal team name', (
      tester,
    ) async {
      final teams = [
        const Team(id: 't1', name: 'Αετοί', score: 5, color: Colors.purple),
        const Team(id: 't2', name: 'Λέοντες', score: 3, color: Colors.blue),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreboardDialog(
              teams: teams,
              currentRound: 2,
              onNextRound: () {},
              onFinishGame: () {},
            ),
          ),
        ),
      );

      // Verify leader text with colon
      expect(find.textContaining('Προηγείται:'), findsOneWidget);
      expect(find.textContaining('Αετοί'), findsWidgets);
      expect(find.textContaining('!'), findsNothing);
    });

    testWidgets(
      'Handles unusually long team names on narrow screen without RenderFlex overflow',
      (tester) async {
        // Set narrow screen size (320px wide)
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final teams = [
          const Team(
            id: 't1',
            name:
                'Η Απίστευτα Μεγάλη και Ακατανίκητη Ομάδα των Ατρόμητων Παντομιμάδων της Αθήνας',
            score: 12,
            color: Colors.purple,
          ),
          const Team(
            id: 't2',
            name: 'Δεύτερη Ομάδα Με Επίσης Πολύ Μεγάλο Όνομα',
            score: 8,
            color: Colors.blue,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ScoreboardDialog(
                  teams: teams,
                  currentRound: 3,
                  onNextRound: () {},
                  onFinishGame: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Must display leader with colon
        expect(find.textContaining('Προηγείται:'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
