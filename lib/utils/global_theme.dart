import 'package:flutter/material.dart';

final primaryColor = Color.fromRGBO(51, 51, 51, 1);
final accentColor = Color.fromRGBO(255, 255, 0, 1);

ThemeData setTheme() {
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
        border: OutlineInputBorder(borderSide: BorderSide(color: accentColor))),
    appBarTheme: AppBarTheme(
        textTheme: TextTheme(headline6: TextStyle(color: accentColor, fontSize: 20.0)),
        iconTheme: IconThemeData(color: accentColor)),
  );
}
