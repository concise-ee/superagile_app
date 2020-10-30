import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
                style: TextStyle(color: Colors.yellowAccent, fontSize: 90),
              )),
          borderSide: BorderSide(width: 1.0, color: Color.fromRGBO(140, 140, 140, 1.0), style: BorderStyle.solid),
          onPressed: onPressed,
        ));
  }
}
