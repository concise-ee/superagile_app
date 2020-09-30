import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/constants/labels.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/repositories/game_repository.dart';

class GameStartWaitingPage extends StatefulWidget {
  final String _name;
  final int _pin;

  GameStartWaitingPage(this._pin, this._name);

  @override
  _GameStartWaitingPageState createState() => _GameStartWaitingPageState();
}

class _GameStartWaitingPageState extends State<GameStartWaitingPage> {
  final GameRepository _gameRepository = GameRepository();
  String playerName;
  int pin;
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(Duration(seconds: 10), (Timer t) => sendLastActive());
  }

  sendLastActive() {
    _gameRepository.findGameByPin(pin).then((game) {
      var currentPlayer =
          game.players.where((player) => player.name == playerName).first;
      currentPlayer.lastActive = DateTime.now().toString();
      _gameRepository.updateGame(game);
    });
  }

  @override
  Widget build(BuildContext context) {
    pin = widget._pin;
    playerName = widget._name;

    return WillPopScope(
      onWillPop: () async {
        timer.cancel();
        return true;
      },
      child: Scaffold(
          appBar: AppBar(title: Text(HASH_SUPERAGILE)),
          body: Container(
              padding: EdgeInsets.all(25),
              child: ListView(
                children: [
                  Text(WAITING_ROOM,
                      style: Theme.of(context).textTheme.headline4),
                  Text(pin.toString(),
                      style: Theme.of(context).textTheme.headline6),
                  findPlayersWithPin(pin)
                ],
              ))),
    );
  }

  Widget findPlayersWithPin(int pin) {
    return StreamBuilder<QuerySnapshot>(
        stream: _gameRepository.getStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          Game game = snapshot.data.documents
              .where((element) => element["pin"] == pin)
              .map((snap) => Game.fromSnapshot(snap))
              .single;
          return findActivePlayers(game);
        });
  }

  Text findActivePlayers(Game game) {
    var activePLayers = game.players.where((player) =>
        DateTime.parse(player.lastActive)
            .isAfter(DateTime.now().subtract(Duration(seconds: 11))));
    return Text("$activePLayers");
  }
}
