import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/player_service.dart';
import 'package:superagile_app/ui/components/play_button.dart';
import 'package:superagile_app/ui/views/game_question_page.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/labels.dart';

import 'final_page.dart';

class CongratulationsPage extends StatefulWidget {
  final int _questionNr;
  final DocumentReference _playerRef;
  final DocumentReference _gameRef;

  CongratulationsPage(this._questionNr, this._playerRef, this._gameRef);

  @override
  _CongratulationsPage createState() => _CongratulationsPage(this._questionNr, this._playerRef, this._gameRef);
}

class _CongratulationsPage extends State<CongratulationsPage> {
  final int questionNr;
  final DocumentReference playerRef;
  final DocumentReference gameRef;
  final GameService gameService = GameService();
  final PlayerService playerService = PlayerService();
  StreamSubscription<DocumentSnapshot> gameStream;
  bool isHost;
  bool isLoading = true;

  _CongratulationsPage(this.questionNr, this.playerRef, this.gameRef);

  @override
  void initState() {
    super.initState();
    loadDataAndSetupListener();
  }

  @override
  void dispose() {
    gameStream.cancel();
    super.dispose();
  }

  void loadDataAndSetupListener() async {
    await loadData();
    if (!isHost) {
      listenForUpdateToGoToNextQuestion();
    }
  }

  void listenForUpdateToGoToNextQuestion() async {
    gameStream = gameService.getGameStream(gameRef).listen((data) async {
      String gameState = await gameService.getGameState(gameRef);
      if (!isHost && gameState.contains(GameState.QUESTION)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return GameQuestionPage(parseSequenceNumberFromGameState(gameState), playerRef, gameRef);
          }),
        );
      }
      if (!isHost && gameState == GameState.FINAL) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return FinalPage(playerRef, gameRef);
          }),
        );
      }
    });
  }

  Future<void> loadData() async {
    bool host = await playerService.isPlayerHosting(playerRef);
    setState(() {
      isHost = host;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(HASH_SUPERAGILE)),
      body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Container(
                        child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Text('${TEAMS_RESULTS} ${questionNr.toString()}:',
                      style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 1.5),
                      textAlign: TextAlign.center),
                ))),
              ],
            ),
          ],
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        CONGRATS,
                        style: TextStyle(
                            color: Colors.yellowAccent, fontSize: 28, letterSpacing: 3, fontWeight: FontWeight.bold),
                      )),
                ))
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      GREAT_MINDS,
                      style: TextStyle(color: Colors.yellowAccent, fontSize: 22, letterSpacing: 1.5),
                    )),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(isHost ? GO_TO_NEXT_QUESTION : WAIT_FOR_NEXT_QUESTION,
                        style: TextStyle(color: Colors.yellowAccent, fontSize: 14, letterSpacing: 1.5),
                        textAlign: TextAlign.center)),
              ),
            )
          ],
        ),
        if (isHost)
          Row(
            children: [
              Expanded(
                  child: Align(
                alignment: Alignment.bottomLeft,
                child: PlayButton(
                  onPressed: () {
                    if (questionNr == 2) {
                      gameService.changeGameState(gameRef, GameState.FINAL);
                      return Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return FinalPage(playerRef, gameRef);
                        }),
                      );
                    }
                    gameService.changeGameState(gameRef, '${GameState.QUESTION}_${questionNr + 1}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return GameQuestionPage(questionNr + 1, playerRef, gameRef);
                      }),
                    );
                  },
                ),
              ))
            ],
          )
      ],
    );
  }
}
