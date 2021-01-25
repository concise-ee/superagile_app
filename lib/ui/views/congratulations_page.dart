import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/entities/question_template.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/player_service.dart';
import 'package:superagile_app/services/question_service.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/game_pin.dart';
import 'package:superagile_app/ui/components/play_button.dart';
import 'package:superagile_app/ui/views/game_question_page.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/labels.dart';

import 'final_page.dart';

const NUMBER_OF_GAME_QUESTIONS = 13;

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
  final QuestionService questionService = QuestionService();
  StreamSubscription<DocumentSnapshot> gameStream;
  bool isHost;
  bool isLoading = true;
  String agreedScore;
  QuestionTemplate questionByNumber;
  int gamePin;

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
    listenForUpdateToGoToNextQuestion();
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
    bool isHost = await playerService.isPlayerHosting(playerRef);
    String agreedScore = await getAgreedScore();
    QuestionTemplate questionByNumber = await questionService.findQuestionByNumber(questionNr);
    var pin = await gameService.getGamePinByRef(gameRef);
    setState(() {
      this.isHost = isHost;
      this.agreedScore = agreedScore;
      this.isLoading = false;
      this.questionByNumber = questionByNumber;
      this.gamePin = pin;
    });
  }

  Future<String> getAgreedScore() async {
    int agreedScore = await gameService.getAgreedScoreForQuestion(gameRef, questionNr);
    if (agreedScore == null) return NO_SCORE;
    return agreedScore.toString();
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
        body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Flexible(
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
                  )))
        ]),
        Expanded(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [GamePin(gamePin: this.gamePin)]),
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
                    if (questionNr == NUMBER_OF_GAME_QUESTIONS) {
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
