import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/entities/question_template.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/question_service.dart';
import 'package:superagile_app/ui/views/question_results_page.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/labels.dart';

class GameQuestionPage extends StatefulWidget {
  final int _questionNr;
  final DocumentReference _playerRef;
  final DocumentReference _gameRef;

  GameQuestionPage(this._questionNr, this._playerRef, this._gameRef);

  @override
  _GameQuestionPage createState() => _GameQuestionPage(this._questionNr, this._playerRef, this._gameRef);
}

class _GameQuestionPage extends State<GameQuestionPage> {
  final QuestionService questionService = QuestionService();
  final GameService gameService = GameService();
  final int questionNr;
  final DocumentReference playerRef;
  final DocumentReference gameRef;
  Question question;
  int pressedButton;
  List<StreamSubscription<QuerySnapshot>> playerQuestionStreams = [];
  StreamSubscription<DocumentSnapshot> gameStream;
  bool isHost = false;

  _GameQuestionPage(this.questionNr, this.playerRef, this.gameRef);

  @override
  void setState(state) {
    if (mounted) {
      super.setState(state);
    }
  }

  @override
  void initState() {
    super.initState();
    loadIsHostAndSetupListeners();
  }

  @override
  void dispose() {
    playerQuestionStreams.forEach((stream) {
      stream.cancel();
    });
    gameStream.cancel();
    super.dispose();
  }

  void loadIsHostAndSetupListeners() async {
    await loadIsHost();
    listenForUpdateToGoToQuestionResultsPage();
  }

  Future<void> loadIsHost() async {
    bool host = await gameService.isPlayerHosting(playerRef);
    setState(() {
      isHost = host;
    });
  }

  void listenForUpdateToGoToQuestionResultsPage() async {
    listenGameStateChanges();
    listenEveryGamePlayerScoreChanges();
  }

  void listenGameStateChanges() async {
    gameStream = gameService.getGameStream(gameRef).listen((data) async {
      String gameState = await gameService.getGameState(gameRef);
      if (!isHost && gameState.contains(GameState.QUESTION_RESULTS)) {
        navigateToQuestionResultsPage();
      }
    });
  }

  void listenEveryGamePlayerScoreChanges() async {
    List<Player> players = await gameService.findGamePlayers(gameRef);
    for (var player in players) {
      StreamSubscription<QuerySnapshot> stream = gameService.getScoresStream(player.reference).listen((data) async {
        QuestionScores questionScores = await gameService.findScoresForQuestion(gameRef, questionNr);
        int answeredPlayersCount = gameService.getAnsweredPlayersCount(questionScores);

        if (players.length == answeredPlayersCount) {
          if (isHost) {
            await gameService.changeGameState(gameRef, '${GameState.QUESTION_RESULTS}_$questionNr');
            navigateToQuestionResultsPage();
          }
        }
      });
      playerQuestionStreams.add(stream);
    }
  }

  void navigateToQuestionResultsPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return QuestionResultsPage(questionNr: questionNr, gameRef: gameRef, playerRef: playerRef);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    loadQuestionContentByNumber();
    return Scaffold(
      appBar: AppBar(title: Text(HASH_SUPERAGILE)),
      body: _buildBody(context),
    );
  }

  void loadQuestionContentByNumber() async {
    final Question questionByNumber = await questionService.findQuestionByNumber(questionNr);
    setState(() {
      question = questionByNumber;
    });
  }

  void saveScoreAndWaitForNextPage(String buttonValue) async {
    await gameService.saveOrSetScore(playerRef, gameRef, questionNr, int.parse(buttonValue));
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                            fit: FlexFit.tight,
                            flex: 2,
                            child: Container(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    questionNr.toString(),
                                    style: TextStyle(color: Colors.white, fontSize: 90, letterSpacing: 1.5),
                                  )),
                            )),
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  question != null ? question.question : '',
                                  style: TextStyle(color: Colors.white, fontSize: 18, height: 1.2, letterSpacing: 1.5),
                                )),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                question != null ? question.zeroMeaning : '',
                                style: TextStyle(color: Colors.yellowAccent, fontSize: 18, letterSpacing: 1.5),
                              )),
                        )),
                    Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                question != null ? question.oneMeaning : '',
                                style: TextStyle(color: Colors.yellowAccent, fontSize: 18, letterSpacing: 1.5),
                              )),
                        )),
                    Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                question != null ? question.twoMeaning : '',
                                style: TextStyle(color: Colors.yellowAccent, fontSize: 18, letterSpacing: 1.5),
                              )),
                        )),
                    Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                question != null ? question.threeMeaning : '',
                                style: TextStyle(color: Colors.yellowAccent, fontSize: 18, letterSpacing: 1.5),
                              )),
                        )),
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 1,
                      child: Container(
                          alignment: Alignment.center,
                          child: Padding(
                              padding: EdgeInsets.only(
                                left: 5,
                                right: 5,
                                top: 25,
                                bottom: 25,
                              ),
                              child: Text(
                                question != null ? question.shortDesc : '',
                                style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1.5),
                                textAlign: TextAlign.center,
                              ))),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              question != null ? question.longDesc : '',
                              style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.5),
                            )),
                      ),
                    ),
                  ],
                ))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: RaisedButton(
                child: Text(
                  ZERO,
                  style: TextStyle(color: ZERO == pressedButton.toString() ? Colors.black : Colors.yellowAccent),
                ),
                color: ZERO == pressedButton.toString() ? Colors.yellowAccent : Colors.black,
                focusColor: Color.fromARGB(1, 0, 0, 255),
                onPressed: () {
                  setState(() {
                    pressedButton = int.parse(ZERO);
                  });
                  saveScoreAndWaitForNextPage(ZERO);
                },
              ),
            ),
            Expanded(
              child: RaisedButton(
                child: Text(ONE,
                    style: TextStyle(color: ONE == pressedButton.toString() ? Colors.black : Colors.yellowAccent)),
                color: ONE == pressedButton.toString() ? Colors.yellowAccent : Colors.black,
                onPressed: () {
                  setState(() {
                    pressedButton = int.parse(ONE);
                  });
                  saveScoreAndWaitForNextPage(ONE);
                },
              ),
            ),
            Expanded(
              child: RaisedButton(
                child: Text(TWO,
                    style: TextStyle(color: TWO == pressedButton.toString() ? Colors.black : Colors.yellowAccent)),
                color: TWO == pressedButton.toString() ? Colors.yellowAccent : Colors.black,
                onPressed: () {
                  setState(() {
                    pressedButton = int.parse(TWO);
                  });
                  saveScoreAndWaitForNextPage(TWO);
                },
              ),
            ),
            Expanded(
              child: RaisedButton(
                child: Text(THREE,
                    style: TextStyle(color: THREE == pressedButton.toString() ? Colors.black : Colors.yellowAccent)),
                color: THREE == pressedButton.toString() ? Colors.yellowAccent : Colors.black,
                onPressed: () {
                  setState(() {
                    pressedButton = int.parse(THREE);
                  });
                  saveScoreAndWaitForNextPage(THREE);
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
