import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/utils/global_theme.dart';

class AgileButton extends StatelessWidget {
  AgileButton({@required this.onPressed, @required this.buttonTitle});

  final GestureTapCallback onPressed;
  final String buttonTitle;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
        fit: BoxFit.fitWidth,
        child: OutlineButton(
          child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 200.0),
              child: Text(
                buttonTitle,
                style: TextStyle(color: accentColor, fontSize: 90),
              )),
          borderSide: BorderSide(width: 1.0, color: secondaryColor, style: BorderStyle.solid),
          onPressed: onPressed,
        ));
  }
}
