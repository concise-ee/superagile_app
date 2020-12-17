import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/entities/question_template.dart';
import 'package:superagile_app/entities/role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/player_service.dart';
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
  static const int HOST_SKIP_VALUE = -1;
  final QuestionService questionService = QuestionService();
  final GameService gameService = GameService();
  final PlayerService playerService = PlayerService();
  final int questionNr;
  final DocumentReference playerRef;
  final DocumentReference gameRef;
  Question question;
  int pressedButton;
  List<StreamSubscription<QuerySnapshot>> playerQuestionStreams = [];
  StreamSubscription<DocumentSnapshot> gameStream;
  Player currentPlayer;
  bool isLoading = true;

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
    loadDataAndSetupListeners();
  }

  @override
  void dispose() {
    playerQuestionStreams.forEach((stream) {
      stream.cancel();
    });
    gameStream.cancel();
    super.dispose();
  }

  void loadDataAndSetupListeners() async {
    await loadData();
    listenForUpdateToGoToQuestionResultsPage();
  }

  Future<void> loadData() async {
    Player player = await playerService.findGamePlayerByRef(playerRef);
    final Question questionByNumber = await questionService.findQuestionByNumber(questionNr);
    setState(() {
      currentPlayer = player;
      question = questionByNumber;
      isLoading = false;
    });
  }

  void listenForUpdateToGoToQuestionResultsPage() async {
    listenGameStateChanges();
    listenEveryGamePlayerScoreChanges();
  }

  void listenGameStateChanges() async {
    gameStream = gameService.getGameStream(gameRef).listen((data) async {
      String gameState = await gameService.getGameState(gameRef);
      if (currentPlayer.role != Role.HOST && gameState.contains(GameState.QUESTION_RESULTS)) {
        navigateToQuestionResultsPage();
      }
    });
  }

  void listenEveryGamePlayerScoreChanges() async {
    List<Player> players = await playerService.findGamePlayers(gameRef);
    for (var player in players) {
      StreamSubscription<QuerySnapshot> stream = gameService.getScoresStream(player.reference).listen((data) async {
        QuestionScores questionScores = await gameService.findScoresForQuestion(gameRef, questionNr);
        int answeredPlayerCount = gameService.getAnsweredPlayersCount(questionScores);

        if (currentPlayer.role == Role.HOST && players.length == answeredPlayerCount) {
          await gameService.changeGameState(gameRef, '${GameState.QUESTION_RESULTS}_$questionNr');
          navigateToQuestionResultsPage();
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
    return Scaffold(
      appBar: AppBar(title: Text(HASH_SUPERAGILE)),
      body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context),
    );
  }

  void saveScoreAndWaitForNextPage(String buttonValue) async {
    await gameService.saveOrSetScore(playerRef, gameRef, questionNr, buttonValue);
  }

  Widget buildBody(BuildContext context) {
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
                                  question.question,
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
                                question.zeroMeaning,
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
                                question.oneMeaning,
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
                                question.twoMeaning,
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
                                question.threeMeaning,
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
                                question.shortDesc,
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
                              question.longDesc,
                              style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.5),
                            )),
                      ),
                    ),
                  ],
                ))),
        if (currentPlayer.role != Role.HOST || (currentPlayer.role == Role.HOST && currentPlayer.isPlayingAlong))
          renderScoreButtons()
        else
          renderContinueButton(),
      ],
    );
  }

  Row renderScoreButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: RaisedButton(
            child: Text(
              ZERO,
              style: TextStyle(color: ZERO == pressedButton.toString() ? Colors.black : Colors.yellowAccent),
            ),
            color: ZERO == pressedButton.toString() ? Colors.yellowAccent : Colors.black,
            onPressed: () {
              setState(() => pressedButton = int.parse(ZERO));
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
              setState(() => pressedButton = int.parse(ONE));
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
              setState(() => pressedButton = int.parse(TWO));
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
              setState(() => pressedButton = int.parse(THREE));
              saveScoreAndWaitForNextPage(THREE);
            },
          ),
        )
      ],
    );
  }

  Row renderContinueButton() {
    return Row(
      children: [
        Expanded(
          child: RaisedButton(
            child: Text(
              CONTINUE,
              style: TextStyle(color: pressedButton == HOST_SKIP_VALUE ? Colors.black : Colors.yellowAccent),
            ),
            color: pressedButton == HOST_SKIP_VALUE ? Colors.yellowAccent : Colors.black,
            onPressed: () {
              setState(() => pressedButton = HOST_SKIP_VALUE);
              saveScoreAndWaitForNextPage(null);
            },
          ),
        )
      ],
    );
  }
}
