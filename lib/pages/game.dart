import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final _random = new Random();

_generate6DigitPin() => _random.nextInt(900000) + 100000;

class GamePage extends StatefulWidget {
  final int _pin;

  GamePage(this._pin);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int pin;

  @override
  Widget build(BuildContext context) {
    pin = widget._pin;
    if (pin == null) {
      pin = _generate6DigitPin();
      Firestore.instance.collection("active_game_pins").add({"value": pin});
    }

    return Scaffold(
      appBar: AppBar(title: Text('#superagile')),
      body: Center(
        child: Text('PIN: $pin', style: Theme.of(context).textTheme.headline4),
      ),
    );
  }
}
