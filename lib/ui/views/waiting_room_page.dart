import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/user_role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/player_service.dart';
import 'package:superagile_app/services/timer_service.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/play_button.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/labels.dart';

import 'game_question_page.dart';

const String QUESTION_1 = '${GameState.QUESTION}_1';

class WaitingRoomPage extends StatefulWidget {
  final DocumentReference _gameRef;
  final DocumentReference _playerRef;

  WaitingRoomPage(this._gameRef, this._playerRef);

  @override
  _WaitingRoomPageState createState() => _WaitingRoomPageState(this._gameRef, this._playerRef);
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  final GameService gameService = GameService();
  final PlayerService playerService = PlayerService();
  final DocumentReference gameRef;
  final DocumentReference playerRef;
  Timer timer;
  String gamePin = '';
  StreamSubscription<DocumentSnapshot> gameStream;
  UserRole userRole;
  bool isLoading = true;

  _WaitingRoomPageState(this.gameRef, this.playerRef);

  @override
  void setState(state) {
    if (mounted) {
      super.setState(state);
    }
  }

  @override
  void initState() {
    super.initState();
    startActivityTimer(playerRef);
    loadDataAndSetupListener();
  }

  void loadDataAndSetupListener() async {
    await loadData();
    listenForUpdateToGoToQuestionPage();
  }

  Future<void> loadData() async {
    Game game = await gameService.findActiveGameByRef(gameRef);
    Player player = await playerService.findGamePlayerByRef(playerRef);
    setState(() {
      gamePin = game.pin.toString();
      userRole = player.role;
      isLoading = false;
    });
  }

  void listenForUpdateToGoToQuestionPage() {
    gameStream = gameService.getGameStream(gameRef).listen((event) async {
      if (Game.fromSnapshot(event).gameState == QUESTION_1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return GameQuestionPage(1, playerRef, gameRef);
          }),
        );
      }
    });
  }

  @override
  void dispose() {
    gameStream.cancel();
    super.dispose();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => BackDialogAlert(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
          appBar: AppBar(title: Text(HASH_SUPERAGILE), automaticallyImplyLeading: false),
          body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody()),
    );
  }

  ListView buildBody() {
    return ListView(
      children: [
        Align(
          alignment: Alignment.center,
        ),
        Container(
            child: Text(WAITING_ROOM,
                textAlign: TextAlign.center, style: TextStyle(color: Color(0xffE5E5E5), fontSize: 35))),
        BorderedText(gamePin),
        if (userRole == UserRole.HOST) buildText(CODE_SHARE_CALL),
        buildText(WAIT_FOR_TEAM),
        if (userRole == UserRole.HOST) buildText(PLAY_BUTTON_CALL),
        if (userRole == UserRole.HOST) buildStartGameButton(),
        buildPlayerCount(),
        Container(child: buildActivePlayersWidget()),
      ],
    );
  }

  Widget buildPlayerCount() {
    return StreamBuilder<QuerySnapshot>(
        stream: playerService.getGamePlayersStream(gameRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          var players = playerService.findActivePlayers(snapshot.data.docs);
          return FittedBox(
              fit: BoxFit.fitWidth,
              child: Text('There are ' + players.length.toString() + ' people in this game.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 24)));
        });
  }

  Widget buildActivePlayersWidget() {
    return StreamBuilder<QuerySnapshot>(
        stream: playerService.getGamePlayersStream(gameRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          var players = playerService.findActivePlayers(snapshot.data.docs);
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
      gameService.changeGameState(gameRef, QUESTION_1);
    });
  }

  Widget buildText(String text) {
    return Text(text, textAlign: TextAlign.center, style: TextStyle(color: Colors.yellowAccent));
  }

  Widget BorderedText(String text) {
    return Container(
      margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(border: Border.all(width: 3.0, color: Color(0xff656565))),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 60),
      ),
    );
  }
}
