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
    return Container(
      width: 400,
      height: 80,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60.0), side: BorderSide(color: agileButtonBorderColor, width: 3)),
        color: black,
        elevation: 5,
        child: Text(
          buttonTitle,
          style: TextStyle(color: accentColor, fontSize: 20),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
