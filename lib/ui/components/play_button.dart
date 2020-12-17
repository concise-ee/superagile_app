import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlayButton extends StatelessWidget {
  PlayButton({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
        fit: BoxFit.fitWidth,
        child: IconButton(
          icon: Icon(Icons.play_arrow),
          padding: EdgeInsets.symmetric(horizontal: 200.0),
          color: Colors.yellowAccent,
          iconSize: 300.0,
          onPressed: onPressed,
        ));
  }
}
