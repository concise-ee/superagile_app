import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:superagile_app/ui/views/start_page.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/utils/log_utils.dart';
import 'package:superagile_app/utils/mixpanel_utils.dart';

final _log = Logger((SuperagileApp).toString());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initLogger();
  FlutterError.onError = (FlutterErrorDetails details) async {
    _log.severe('${details.exception}:\n${details.stack}');
  };
  runZonedGuarded<Future<void>>(() async {
    initMixpanel();
    _log.info('BEST TOKEN EVER-> ' + String.fromEnvironment('MIXPANEL_TOKEN'));
    runApp(SuperagileApp());
  }, (Object error, StackTrace stackTrace) {
    _log.severe('${error}:\n${stackTrace}');
  });
}

class SuperagileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: SUPERAGILE, home: StartPage(), theme: setTheme());
  }
}
