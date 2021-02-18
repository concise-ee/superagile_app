// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

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

    final buttonFinder = find.text(PLAYING_ALONG);
    final emptyNameErrorFinder = find.text(WARNING_NAME_EMPTY);

    await tester.tap(buttonFinder);
    print('button tapped');
    await tester.pump(const Duration(milliseconds: 100)); // add delay
    expect(emptyNameErrorFinder, findsOneWidget);
    print('validated empty name error');
  });

  testWidgets('Host start page does not allow too long name', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget(HostStartPage()));

    // final nameErrorFinder = find.text(WARNING_NAME_TOO_LONG);
    // final nameErrorFinder = find.text(WARNING_NAME_EMPTY);
    final nameFieldFinder = find.byKey(Key('nameField'));
    final buttonFinder = find.text(PLAYING_ALONG);

    await tester.enterText(nameFieldFinder, 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');

    await tester.tap(buttonFinder);
    print('button tapped');
    await tester.pump(const Duration(milliseconds: 100)); // add delay
    final nameErrorFinder = find.text(WARNING_NAME_TOO_LONG);
    expect(nameErrorFinder, findsOneWidget);
    print('validated name too long error');
  });
}

Widget makeTestableWidget(Widget child) {
  return MaterialApp(home: child);
}
