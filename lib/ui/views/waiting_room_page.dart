import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/utils/labels.dart';

import 'game_question_page.dart';

class WaitingRoomPage extends StatefulWidget {
  final DocumentReference _gameRef;
  final DocumentReference _playerRef;

  WaitingRoomPage(this._gameRef, this._playerRef);

  @override
  _WaitingRoomPageState createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  final GameService gameService = GameService();
  DocumentReference gameRef;
  DocumentReference playerRef;
  Timer timer;
  String gamePin = '';

  @override
  void setState(state) {
    if (mounted) {
      super.setState(state);
    }
  }

  void loadGame() async {
    Game game = await gameService.findActiveGameByRef(gameRef);
    setState(() {
      gamePin = game.pin.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      gameService.sendLastActive(playerRef);
    });
  }

  @override
  Widget build(BuildContext context) {
    gameRef = widget._gameRef;
    playerRef = widget._playerRef;
    loadGame();
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
              Text(gamePin, style: Theme.of(context).textTheme.headline5),
              buildActivePlayersWidget(),
              buildStartGameButton(),
            ],
          )),
    );
  }

  Widget buildActivePlayersWidget() {
    return StreamBuilder<QuerySnapshot>(
        stream: gameService.getGamePlayersStream(gameRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          var players = gameService.findActivePlayers(snapshot.data.docs);
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

  Widget buildStartGameButton() {
    return AgileButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return GameQuestionPage(1, playerRef, gameRef);
            }),
          );
        },
        buttonTitle: BEGIN_GAME);
  }
}
