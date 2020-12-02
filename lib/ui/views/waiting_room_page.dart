import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/ui/components/play_button.dart';
import 'package:superagile_app/utils/labels.dart';

import 'game_question_page.dart';

class WaitingRoomPage extends StatefulWidget {
  final DocumentReference _gameRef;
  final DocumentReference _playerRef;

  WaitingRoomPage(this._gameRef, this._playerRef);

  @override
  _WaitingRoomPageState createState() =>
      _WaitingRoomPageState(this._gameRef, this._playerRef);
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  final GameService gameService = GameService();
  final DocumentReference gameRef;
  final DocumentReference playerRef;
  Timer timer;
  bool isHost = false;
  String gamePin = '';

  _WaitingRoomPageState(this.gameRef, this.playerRef);

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
    loadIsHost();
    loadGame();
  }

  void loadIsHost() async {
    bool host = await gameService.isPlayerHosting(playerRef);
    setState(() {
      isHost = host;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        timer.cancel();
        return true;
      },
      child: Scaffold(
          appBar: AppBar(title: Text(HASH_SUPERAGILE)),
          body: ListView(
            children: [
              Align(
                alignment: Alignment.center,
              ),
              Container(
                  child: Text(WAITING_ROOM,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Color(0xffE5E5E5), fontSize: 35))),
              BorderedText(gamePin),
              if (isHost) buildText(CODE_SHARE_CALL),
              buildText('Paragraph'),
              if (isHost) buildText(PLAY_BUTTON_CALL),
              if (isHost) buildStartGameButton(),
              buildPlayerCount(),
              Container(child: buildActivePlayersWidget()),
            ],
          )),
    );
  }

  Widget buildPlayerCount() {
    return StreamBuilder<QuerySnapshot>(
        stream: gameService.getGamePlayersStream(gameRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          var players = gameService.findActivePlayers(snapshot.data.docs);
          return FittedBox(
              fit: BoxFit.fitWidth,
              child:  Text('There are ' + players.length.toString() + ' people in this game.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24)));
        });
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
                title: Text(
                  players[index].name,
                  style: TextStyle(color: Color(0xffFFFFFF)),
                ),
                subtitle: Center(child: Text(players[index].lastActive)),
              );
            },
          );
        });
  }

  Widget buildStartGameButton() {
    return PlayButton(onPressed: () {
      FocusScope.of(context).unfocus();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return GameQuestionPage(1, playerRef, gameRef);
        }),
      );
    });
  }

  Widget buildText(String text) {
    return Text(text,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.yellowAccent));
  }

  Widget BorderedText(String text) {
    return Container(
      margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          border: Border.all(width: 3.0, color: Color(0xff656565))),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 60),
      ),
    );
  }
}
