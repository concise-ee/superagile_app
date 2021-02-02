import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/entities/question_template.dart';
import 'package:superagile_app/entities/role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/participant_service.dart';
import 'package:superagile_app/services/question_service.dart';
import 'package:superagile_app/services/score_service.dart';
import 'package:superagile_app/services/timer_service.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/button_percent_popup.dart';
import 'package:superagile_app/ui/components/game_pin.dart';
import 'package:superagile_app/ui/views/question_results_page.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/utils/list_utils.dart';

final _log = Logger((GameQuestionPage).toString());

class GameQuestionPage extends StatefulWidget {
  final int _questionNr;
  final DocumentReference _participantRef;
  final DocumentReference _gameRef;

  GameQuestionPage(this._questionNr, this._participantRef, this._gameRef);

  @override
  _GameQuestionPage createState() => _GameQuestionPage(this._questionNr, this._participantRef, this._gameRef);
}

class _GameQuestionPage extends State<GameQuestionPage> {
  static const int HOST_SKIP_VALUE = -1;
  final QuestionService questionService = QuestionService();
  final GameService gameService = GameService();
  final ParticipantService participantService = ParticipantService();
  final ScoreService scoreService = ScoreService();
  final TimerService timerService = TimerService();
  final int questionNr;
  final DocumentReference participantRef;
  final DocumentReference gameRef;
  QuestionTemplate questionTemplate;
  int pressedButton;
  List<StreamSubscription<QuerySnapshot>> participantScoreStreams = [];
  StreamSubscription<DocumentSnapshot> gameStream;
  StreamSubscription<QuerySnapshot> participantsStream;
  Role role;
  bool isPlayingAlong;
  bool isLoading = true;
  int gamePin;

  _GameQuestionPage(this.questionNr, this.participantRef, this.gameRef);

  @override
  void setState(state) {
    if (mounted) {
      super.setState(state);
    }
  }

  @override
  void initState() {
    super.initState();
    timerService.startActivityTimer(participantRef);
    loadDataAndSetupListeners();
  }

  @override
  void dispose() {
    cancelParticipantsScoreStreams();
    if (gameStream != null) {
      gameStream.cancel();
    }
    if (participantsStream != null) {
      participantsStream.cancel();
    }
    super.dispose();
  }

  void loadDataAndSetupListeners() async {
    await loadData();
    listenForUpdateToGoToQuestionResultsPage();
  }

  Future<void> loadData() async {
    Participant participant = await participantService.findGameParticipantByRef(participantRef);
    final QuestionTemplate questionByNumber = await questionService.findQuestionByNumber(questionNr);
    var pin = await gameService.getGamePinByRef(gameRef);
    setState(() {
      role = participant.role;
      isPlayingAlong = participant.isPlayingAlong;
      questionTemplate = questionByNumber;
      isLoading = false;
      gamePin = pin;
    });
  }

  void listenForUpdateToGoToQuestionResultsPage() async {
    if (role == Role.PLAYER) {
      listenGameStateChanges();
    } else if (role == Role.HOST) {
      listenEveryActiveParticipantScoreChanges();
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

  void listenEveryActiveParticipantScoreChanges() async {
    List<Participant> activeParticipants = await participantService.findActiveGameParticipants(gameRef);
    setupActiveParticipantsScoreStreams(activeParticipants);
    participantsStream = participantService.getParticipantsStream(gameRef).listen((data) async {
      List<Participant> newActiveParticipants = await participantService.findActiveGameParticipants(gameRef);
      if (!areEqualByName(activeParticipants, newActiveParticipants)) {
        cancelParticipantsScoreStreams();
        activeParticipants = newActiveParticipants;
        setupActiveParticipantsScoreStreams(activeParticipants);
      }
    });
  }

  void setupActiveParticipantsScoreStreams(List<Participant> activeParticipants) {
    for (var participant in activeParticipants) {
      StreamSubscription<QuerySnapshot> stream =
          scoreService.getScoresStream(participant.reference).listen((data) async {
        QuestionScores questionScores = await scoreService.findScoresForQuestion(gameRef, questionNr);
        List<String> answeredParticipantNames = scoreService.getAnsweredParticipantNames(questionScores);
        bool haveAllActiveParticipantsVoted = true;
        for (var activeParticipant in activeParticipants) {
          if (!answeredParticipantNames.contains(activeParticipant.name)) {
            haveAllActiveParticipantsVoted = false;
          }
        }
        if (haveAllActiveParticipantsVoted) {
          await gameService.changeGameState(gameRef, '${GameState.QUESTION_RESULTS}_$questionNr');
          return navigateToQuestionResultsPage();
        }
      });
      participantScoreStreams.add(stream);
    }
  }

  Future<MaterialPageRoute<QuestionResultsPage>> navigateToQuestionResultsPage() {
    _log.info('${participantRef} navigates to QuestionResultsPage, questionNr: ${questionNr}');
    return Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) {
        return QuestionResultsPage(questionNr: questionNr, gameRef: gameRef, participantRef: participantRef);
      }),
    );
  }

  void cancelParticipantsScoreStreams() {
    participantScoreStreams.forEach((stream) {
      stream.cancel();
    });
    participantScoreStreams.clear();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => BackDialogAlert(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () => _onBackPressed(),
        child: Scaffold(
          appBar: AppBar(
              title: Text(HASH_SUPERAGILE), automaticallyImplyLeading: false, actions: <Widget>[ButtonPercentPopup()]),
          body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context),
        ));
  }

  void saveScoreAndWaitForNextPage(String scoreValue) async {
    await scoreService.setScore(participantRef, gameRef, questionNr, scoreValue);
  }

  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Row(children: [GamePin(gamePin: gamePin)]),
        Expanded(
            child: SingleChildScrollView(
                padding: EdgeInsets.only(left: 25, right: 25, bottom: 25),
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
        if (role == Role.PLAYER || (role == Role.HOST && isPlayingAlong))
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
