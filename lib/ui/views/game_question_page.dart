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
import 'package:superagile_app/ui/components/alert_dialog.dart';
import 'package:superagile_app/ui/views/question_results_page.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/globals.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/utils/list_utils.dart';

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
  QuestionTemplate questionTemplate;
  int pressedButton;
  List<StreamSubscription<QuerySnapshot>> playerScoreStreams = [];
  StreamSubscription<DocumentSnapshot> gameStream;
  StreamSubscription<QuerySnapshot> playersStream;
  Player currentPlayer;
  bool isLoading = true;
  int gamePin;
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
    if (activityTimer == null) {
      playerService.sendLastActive(playerRef);
      activityTimer = Timer.periodic(Duration(seconds: 10), (Timer t) {
        playerService.sendLastActive(playerRef);
      });
    }
    loadDataAndSetupListeners();
  }

  @override
  void dispose() {
    cancelPlayersScoreStreams();
    if (gameStream != null) {
      gameStream.cancel();
    }
    if (playersStream != null) {
      playersStream.cancel();
    }
    super.dispose();
  }

  void loadDataAndSetupListeners() async {
    await loadData();
    listenForUpdateToGoToQuestionResultsPage();
  }

  Future<void> loadData() async {
    Player player = await playerService.findGamePlayerByRef(playerRef);
    final QuestionTemplate questionByNumber = await questionService.findQuestionByNumber(questionNr);
    var pin = await gameService.getGamePinByRef(gameRef);
    setState(() {
      currentPlayer = player;
      questionTemplate = questionByNumber;
      isLoading = false;
      gamePin = pin;
    });
  }

  void listenForUpdateToGoToQuestionResultsPage() async {
    if (currentPlayer.role == Role.PLAYER) {
      listenGameStateChanges();
    } else if (currentPlayer.role == Role.HOST) {
      listenEveryActivePlayerScoreChanges();
    }
  }

  void listenGameStateChanges() async {
    gameStream = gameService.getGameStream(gameRef).listen((data) async {
      String gameState = await gameService.getGameState(gameRef);
      if (gameState.contains(GameState.QUESTION_RESULTS)) {
        return navigateToQuestionResultsPage();
      }
    });
  }

  void listenEveryActivePlayerScoreChanges() async {
    List<Player> activePlayers = await playerService.findActiveGamePlayers(gameRef);
    setupActivePlayersScoreStreams(activePlayers);
    playersStream = playerService.getGamePlayersStream(gameRef).listen((data) async {
      List<Player> newActivePlayers = await playerService.findActiveGamePlayers(gameRef);
      if (!areEqualByName(activePlayers, newActivePlayers)) {
        cancelPlayersScoreStreams();
        activePlayers = newActivePlayers;
        setupActivePlayersScoreStreams(activePlayers);
      }
    });
  }

  void setupActivePlayersScoreStreams(List<Player> activePlayers) {
    for (var player in activePlayers) {
      StreamSubscription<QuerySnapshot> stream = gameService.getScoresStream(player.reference).listen((data) async {
        QuestionScores questionScores = await gameService.findScoresForQuestion(gameRef, questionNr);
        int answeredPlayerCount = gameService.getAnsweredPlayersCount(questionScores);
        if (activePlayers.length == answeredPlayerCount) {
          await gameService.changeGameState(gameRef, '${GameState.QUESTION_RESULTS}_$questionNr');
          return navigateToQuestionResultsPage();
        }
      });
      playerScoreStreams.add(stream);
    }
  }

  Future<MaterialPageRoute<QuestionResultsPage>> navigateToQuestionResultsPage() {
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return QuestionResultsPage(questionNr: questionNr, gameRef: gameRef, playerRef: playerRef);
      }),
    );
  }

  void cancelPlayersScoreStreams() {
    playerScoreStreams.forEach((stream) {
      stream.cancel();
    });
    playerScoreStreams.clear();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => DialogAlert(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () => _onBackPressed(),
        child: Scaffold(
          appBar: AppBar(title: Text(HASH_SUPERAGILE), automaticallyImplyLeading: false),
          body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context),
        ));
  }

  void saveScoreAndWaitForNextPage(String buttonValue) async {
    await gameService.setScore(playerRef, gameRef, questionNr, buttonValue);
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
                    Row(children: [
                      Flexible(
                          flex: 1,
                          child: Container(
                              alignment: Alignment.topRight,
                              child: Text(
                                '${GAME_PIN} ${this.gamePin}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              )))
                    ]),
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
                                  questionTemplate.question,
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
                                questionTemplate.zeroMeaning,
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
                                questionTemplate.oneMeaning,
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
                                questionTemplate.twoMeaning,
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
                                questionTemplate.threeMeaning,
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
                                questionTemplate.shortDesc,
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
                              questionTemplate.longDesc,
                              style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.5),
                            )),
                      ),
                    ),
                  ],
                ))),
        if (currentPlayer.role == Role.PLAYER || (currentPlayer.role == Role.HOST && currentPlayer.isPlayingAlong))
          SafeArea(
              child: Row(
            children: [
              renderScoreButton(ZERO),
              renderScoreButton(ONE),
              renderScoreButton(TWO),
              renderScoreButton(THREE)
            ],
          ))
        else
          renderContinueButton(),
      ],
    );
  }

  Expanded renderScoreButton(String value) {
    return Expanded(
      child: Container(
        height: 50,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0), side: BorderSide(color: Colors.grey, width: 2)),
          child: Text(value,
              style: TextStyle(color: value == pressedButton.toString() ? primaryColor : accentColor, fontSize: 24)),
          color: value == pressedButton.toString() ? accentColor : primaryColor,
          onPressed: () {
            setState(() => pressedButton = int.parse(value));
            saveScoreAndWaitForNextPage(value);
          },
        ),
      ),
    );
  }

  Row renderContinueButton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0), side: BorderSide(color: Colors.grey, width: 2)),
              child: Text(
                CONTINUE,
                style: TextStyle(color: pressedButton == HOST_SKIP_VALUE ? primaryColor : accentColor, fontSize: 24),
              ),
              color: pressedButton == HOST_SKIP_VALUE ? accentColor : primaryColor,
              onPressed: () {
                setState(() => pressedButton = HOST_SKIP_VALUE);
                saveScoreAndWaitForNextPage(null);
              },
            ),
          ),
        )
      ],
    );
  }
}
