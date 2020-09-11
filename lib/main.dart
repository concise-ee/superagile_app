import 'package:flutter/material.dart';
import 'package:superagile_app/pages/start.dart';

void main() => runApp(SuperagileApp());

final primaryColor = Colors.grey[800];
final accentColor = Colors.yellow[500];

class SuperagileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Superagile', home: StartPage(), theme: _setTheme());
  }

  ThemeData _setTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      accentColor: accentColor,
      textTheme: TextTheme(
          bodyText1: TextStyle(color: accentColor),
          bodyText2: TextStyle(color: accentColor),
          headline1: TextStyle(color: accentColor),
          headline2: TextStyle(color: accentColor),
          headline3: TextStyle(color: accentColor),
          headline4: TextStyle(color: accentColor),
          headline5: TextStyle(color: accentColor),
          headline6: TextStyle(color: accentColor)),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.accent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: accentColor),
      ),
      appBarTheme: AppBarTheme(
          textTheme: TextTheme(
              headline6: TextStyle(color: accentColor, fontSize: 20.0)),
          iconTheme: IconThemeData(color: accentColor)),
    );
  }
}
