import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/constants/labels.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/repositories/game_repository.dart';

class GameStartWaitingPage extends StatefulWidget {
  final Game _game;
  final String _playerName;

  GameStartWaitingPage(this._game, this._playerName);

  @override
  _GameStartWaitingPageState createState() => _GameStartWaitingPageState();
}

class _GameStartWaitingPageState extends State<GameStartWaitingPage> {
  final GameRepository _gameRepository = GameRepository();
  Game game;
  String playerName;
  Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) => sendLastActive());
  }

  void sendLastActive() async {
    var players = await _gameRepository.findGamePlayers(game.reference);
    var player = players.where((player) => player.name == playerName).single;
    player.lastActive = DateTime.now().toString();
    _gameRepository.updateGamePlayer(game.reference, player);
  }

  @override
  Widget build(BuildContext context) {
    game = widget._game;
    playerName = widget._playerName;

    return WillPopScope(
      onWillPop: () async {
        timer.cancel();
        return true;
      },
      child: Scaffold(
          appBar: AppBar(title: Text(HASH_SUPERAGILE)),
          body: ListView(
            padding: EdgeInsets.all(25),
            children: [
              Text(WAITING_ROOM, style: Theme.of(context).textTheme.headline4),
              Text(game.pin.toString(), style: Theme.of(context).textTheme.headline5),
              buildActivePlayersWidget(game.pin),
            ],
          )),
    );
  }

  Widget buildActivePlayersWidget(int pin) {
    return StreamBuilder<QuerySnapshot>(
        stream: _gameRepository.getGamePlayersStream(game.reference),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          var players = findActivePlayers(snapshot.data.docs);
          return ListView.builder(
            shrinkWrap: true,
            itemCount: players.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(players[index].name),
                subtitle: Text(players[index].lastActive),
              );
            },
          );
        });
  }

  List<Player> findActivePlayers(List<QueryDocumentSnapshot> snaps) {
    return snaps
        .map((playerSnap) => Player.fromSnapshot(playerSnap))
        .where((player) => DateTime.parse(player.lastActive).isAfter(DateTime.now().subtract(Duration(seconds: 11))))
        .toList();
  }
}
