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
  _WaitingRoomPageState createState() => _WaitingRoomPageState();
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  final GameService gameService = GameService();
  DocumentReference gameRef;
  DocumentReference playerRef;
  Timer timer;
  Timer playerTimer;
  int playerNumber;
  bool isHost;
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

  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      gameService.sendLastActive(playerRef);
    });
    playerTimer = Timer.periodic(Duration(seconds: 1), (Timer t) => setPlayerCount());
    playerNumber = 0;

    isHost = true;

  }


  void setPlayerCount() async{
    var players = await gameService.findGamePlayers(gameRef);
    playerNumber = players.length;
    setState(() {});
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
          body:  Column(
            children: [
              Align(
                alignment: Alignment.center,
              ),
              Flexible( child: Text(WAITING_ROOM, textAlign: TextAlign.center, style: TextStyle(color: Color(0xffE5E5E5), fontSize: 35))),
                  BorderedText(gamePin) ,
              if (isHost) buildText('*Share this code with your team.'),
              Spacer(),
              Text('Paragraph'),
              Spacer(),
              if (isHost) buildText('Then click the play button.'),
              if (isHost) buildStartGameButton(),
              FittedBox( fit: BoxFit.fitWidth, child: Text('There are ' + playerNumber.toString() + ' people in this game.',textAlign: TextAlign.center, style: TextStyle(fontSize: 24),)) ,
              Flexible( child:buildActivePlayersWidget()),
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
              return  ListTile(
                title: Text(players[index].name, style: TextStyle(color: Color(0xffFFFFFF)),),
                subtitle: Center(child: Text(players[index].lastActive)),
              );
            },
          );
        });
  }

  Widget buildStartGameButton() {
    return PlayButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return GameQuestionPage(1, playerRef, gameRef);
            }),
          );
        }
    );
  }
  Widget buildText(String text){
    return Text (text, textAlign: TextAlign.center,style: TextStyle(color: Colors.yellowAccent));
  }

  Widget BorderedText(String text) {
    return Container(
      margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(border: Border.all(width: 3.0, color: Color(0xff656565))), //             <--- BoxDecoration here
      child: Text(
        text, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 60),
      ),
    );
  }

}
