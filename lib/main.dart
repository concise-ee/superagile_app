import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/ui/views/start_page.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/utils/log_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initLogger();
  runApp(SuperagileApp());
}

class SuperagileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: SUPERAGILE, home: StartPage(), theme: setTheme());
  }
}
