import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:superagile_app/ui/views/host_start_page.dart';
import 'package:superagile_app/utils/labels.dart';

import 'firebase_mock.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Host start page does not allow empty name', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(HostStartPage()));

    final buttonFinder = find.text(VOTE_WITH_TEAM);
    final emptyNameErrorFinder = find.text(WARNING_NAME_EMPTY);

    await tester.tap(buttonFinder);
    print('button tapped');
    await tester.pump(const Duration(milliseconds: 100)); // add delay
    expect(emptyNameErrorFinder, findsOneWidget);
    print('validated empty name error');
  });
}

Widget makeTestableWidget(Widget child) {
  return MaterialApp(home: child);
}
