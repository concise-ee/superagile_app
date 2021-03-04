import 'package:flutter/material.dart';

const primaryColor = Color.fromRGBO(51, 51, 51, 1);
const accentColor = Color.fromRGBO(255, 255, 0, 1);
const secondaryColor = Color.fromRGBO(167, 168, 170, 1);
const agileButtonBorderColor = Color.fromRGBO(101, 101, 101, 1);
const aboutPageBackgroundColor = Color.fromRGBO(229, 229, 229, 1);
const white = Colors.white;
const black = Colors.black;
const fontExtraExtraSmall = 9.0;
const fontExtraSmall = 12.0;
const fontSmall = 16.0;
const fontMedium = 24.0;
const fontLarge = 36.0;
const fontExtraLarge = 48.0;
const fontExtraExtraLarge = 105.0;

ThemeData setTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: primaryColor,
    accentColor: accentColor,
    textTheme: TextTheme(
        subtitle1: TextStyle(fontSize: 35, color: accentColor),
        bodyText1: TextStyle(color: white),
        bodyText2: TextStyle(color: white),
        headline1: TextStyle(color: white),
        headline2: TextStyle(color: white),
        headline3: TextStyle(color: white),
        headline4: TextStyle(color: white),
        headline5: TextStyle(color: white),
        headline6: TextStyle(color: white)),
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
        textTheme: TextTheme(headline6: TextStyle(color: accentColor, fontSize: 24.0)),
        iconTheme: IconThemeData(color: accentColor)),
  );
}
