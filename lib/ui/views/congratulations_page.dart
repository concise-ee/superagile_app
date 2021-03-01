import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/question_template.dart';
import 'package:superagile_app/entities/role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/participant_service.dart';
import 'package:superagile_app/services/question_service.dart';
import 'package:superagile_app/services/score_service.dart';
import 'package:superagile_app/services/timer_service.dart';
import 'package:superagile_app/ui/components/agile_with_back_icon_button.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/game_pin.dart';
import 'package:superagile_app/ui/components/play_button.dart';
import 'package:superagile_app/ui/views/game_question_page.dart';
import 'package:superagile_app/utils/game_state_router.dart';
import 'package:superagile_app/utils/labels.dart';

import 'final_page.dart';

final _log = Logger((CongratulationsPage).toString());

class CongratulationsPage extends StatefulWidget {
  final int _questionNr;
  final DocumentReference _participantRef;
  final DocumentReference _gameRef;

  CongratulationsPage(this._questionNr, this._participantRef, this._gameRef);

  @override
  _CongratulationsPage createState() => _CongratulationsPage(this._questionNr, this._participantRef, this._gameRef);
}

class _CongratulationsPage extends State<CongratulationsPage> {
  final int questionNr;
  final DocumentReference participantRef;
  final DocumentReference gameRef;
  final GameService gameService = GameService();
  final ParticipantService participantService = ParticipantService();
  final QuestionService questionService = QuestionService();
  final ScoreService scoreService = ScoreService();
  final TimerService timerService = TimerService();
  StreamSubscription<DocumentSnapshot> gameStream;
  Role role;
  bool isLoading = true;
  String agreedScore;
  QuestionTemplate questionByNumber;
  int gamePin;

  _CongratulationsPage(this.questionNr, this.participantRef, this.gameRef);

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
    loadDataAndSetupListener();
  }

  @override
  void dispose() {
    if (role == Role.PLAYER) {
      gameStream.cancel();
    }
    super.dispose();
  }

  void loadDataAndSetupListener() async {
    await loadData();
    if (role == Role.PLAYER) {
      listenForUpdateToGoToNextQuestion();
    }
  }

  void listenForUpdateToGoToNextQuestion() async {
    gameStream = gameService.getGameStream(gameRef).listen((data) async {
      String gameState = await gameService.getGameState(gameRef);
      if (gameState.contains(GameState.QUESTION)) {
        _log.info(
            '${participantRef} navigates to GameQuestionPage, newQuestionNr: ${parseSequenceNumberFromGameState(gameState)}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return GameQuestionPage(parseSequenceNumberFromGameState(gameState), participantRef, gameRef);
          }),
        );
      }
      if (gameState == GameState.FINAL) {
        _log.info('${participantRef} navigates to FinalPage, gameState: ${gameState}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return FinalPage(participantRef, gameRef);
          }),
        );
      }
    });
  }

  Future<void> loadData() async {
    Participant participant = await participantService.findGameParticipantByRef(participantRef);
    String agreedScore = await getAgreedScore();
    QuestionTemplate questionByNumber = await questionService.findQuestionByNumber(questionNr);
    var pin = await gameService.getGamePinByRef(gameRef);
    setState(() {
      this.role = participant.role;
      this.agreedScore = agreedScore;
      this.isLoading = false;
      this.questionByNumber = questionByNumber;
      this.gamePin = pin;
    });
  }

  Future<String> getAgreedScore() async {
    int agreedScore = await scoreService.getAgreedScoreForQuestion(gameRef, questionNr);
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
        appBar: AppBar(title: AgileWithBackIconButton(_onBackPressed), automaticallyImplyLeading: false),
        body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: questionNr / NUMBER_OF_GAME_QUESTIONS,
        ),
        Row(children: [GamePin(gamePin: gamePin)]),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 50),
                  child: Text('${TEAMS_RESULTS} ${questionByNumber.topicName}: ${agreedScore}',
                      style: TextStyle(fontSize: 24), textAlign: TextAlign.center),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 24),
                    child: Text(
                      CONGRATS,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    )),
                Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Text(
                      GREAT_MINDS,
                      style: TextStyle(fontSize: 22),
                    )),
              ],
            ),
          ),
        ),
        if (role == Role.HOST)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 200,
                  child: PlayButton(
                    onPressed: () async {
                      if (questionNr == NUMBER_OF_GAME_QUESTIONS) {
                        await gameService.changeGameState(gameRef, GameState.FINAL);
                        _log.info('${participantRef} HOST changed gameState to: ${GameState.FINAL}');
                        return Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return FinalPage(participantRef, gameRef);
                          }),
                        );
                      }
                      await gameService.changeGameState(gameRef, '${GameState.QUESTION}_${questionNr + 1}');
                      _log.info('${participantRef} HOST changed gameState to: ${GameState.QUESTION}_${questionNr + 1}');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return GameQuestionPage(questionNr + 1, participantRef, gameRef);
                        }),
                      );
                    },
                  ),
                ),
              ),
            ],
          )
      ],
    );
  }
}
