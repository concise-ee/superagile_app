import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/utils/labels.dart';

class GamePin extends StatelessWidget {
  GamePin({@required this.gamePin});

  final int gamePin;

  @override
  Widget build(BuildContext context) {
    return Flexible(
        flex: 1,
        child: Container(
            padding: EdgeInsets.all(25),
            alignment: Alignment.topRight,
            child: Text(
              '${GAME_PIN} ${this.gamePin}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            )));
  }
}
