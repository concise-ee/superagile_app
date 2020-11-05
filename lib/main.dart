import 'package:flutter/material.dart';
import 'package:superagile_app/constants/labels.dart';
import 'package:superagile_app/pages/start_page.dart';

void main() => runApp(SuperagileApp());

final primaryColor = Color.fromRGBO(13, 13, 13, 1);
final accentColor = Colors.yellow[500];

class SuperagileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: SUPERAGILE, home: StartPage(), theme: _setTheme());
  }

  ThemeData _setTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: primaryColor,
      accentColor: accentColor,
      textTheme: TextTheme(
        subtitle1: TextStyle(fontSize: 35, color: accentColor),
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
        hintStyle: TextStyle(color: accentColor, fontSize: 35),

        contentPadding: EdgeInsets.all(15),
        isDense: true,
        border: new OutlineInputBorder(borderSide: new BorderSide( color: accentColor))
      ),
      appBarTheme: AppBarTheme(
          textTheme: TextTheme(
              headline6: TextStyle(color: accentColor, fontSize: 20.0)),
          iconTheme: IconThemeData(color: accentColor)),
    );
  }
}
