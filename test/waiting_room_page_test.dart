import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/participant_service.dart';
import 'package:superagile_app/services/security_service.dart';
import 'package:superagile_app/ui/views/waiting_room_page.dart';

import 'firebase_mock.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Waiting room page displays host name', (WidgetTester tester) async {
    var loggedInUserUid = await signInAnonymously();
    var gameService = GameService();
    var participantService = ParticipantService();
    var pin = await gameService.generateAvailable4DigitPin();
    var gameRef = await gameService.addGame(Game(pin, loggedInUserUid, true, null));
    var hostRef = await participantService.addParticipant(
        gameRef, Participant('hosting_participant', loggedInUserUid, DateTime.now().toString(), Role.HOST, false, true));
    await tester.pumpWidget(makeTestableWidget(WaitingRoomPage(gameRef, hostRef)));

    final nameFinder = find.text('hosting_participant');

    expect(nameFinder, findsOneWidget);
    print('validated waiting room page displays host name');
  });
}

Widget makeTestableWidget(Widget child) {
  return MaterialApp(home: child);
}
