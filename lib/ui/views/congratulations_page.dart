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
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/agile_with_back_icon_button.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/barchart.dart';
import 'package:superagile_app/ui/components/game_pin.dart';
import 'package:superagile_app/ui/components/play_button.dart';
import 'package:superagile_app/ui/views/game_question_page.dart';
import 'package:superagile_app/utils/game_state_router.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/utils/mixpanel_utils.dart';
import 'package:wakelock/wakelock.dart';

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
  List<String> scoreMeanings;
  QuestionTemplate questionByNumber;
  int gamePin;
  var _firstPress = true;

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
    gameStream?.cancel();
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
            int guestionNr = parseSequenceNumberFromGameState(gameState);
            mixpanel.track('Duration for question ' + (guestionNr - 1).toString());
            mixpanel.timeEvent('Duration for question ' + guestionNr.toString());
            gameService.changeGameKeepState(gameRef, false);
            return GameQuestionPage(guestionNr, participantRef, gameRef);
          }),
        );
      }
      if (gameState == GameState.FINAL) {
        _log.info('${participantRef} navigates to FinalPage, gameState: ${gameState}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            mixpanel.track('Duration for question 13');
            gameService.changeGameKeepState(gameRef, false);
            return FinalPage(participantRef, gameRef);
          }),
        );
      }
    });
  }

  Future<void> loadData() async {
    Participant participant = await participantService.findGameParticipantByRef(participantRef);
    String agreedScore = await getAgreedScore();
    List<String> scoreMeanings = await getScoreMeanings();
    QuestionTemplate questionByNumber = await questionService.findQuestionByNumber(questionNr);
    var pin = await gameService.getGamePinByRef(gameRef);
    setState(() {
      this.role = participant.role;
      this.agreedScore = agreedScore;
      this.scoreMeanings = scoreMeanings;
      this.isLoading = false;
      this.questionByNumber = questionByNumber;
      this.gamePin = pin;
    });
  }

  Future<String> getAgreedScore() async {
    int agreedScore = await scoreService.getAgreedScoreForQuestion(gameRef, questionNr);
    if (agreedScore == null) return null;
    return agreedScore.toString();
  }

  Future<List<String>> getScoreMeanings() async {
    QuestionTemplate questionTemplate = await questionService.findQuestionByNumber(questionNr);
    return List.unmodifiable([
      '',
      '0. ' + questionTemplate.zeroMeaning,
      '1. ' + questionTemplate.oneMeaning,
      '2. ' + questionTemplate.twoMeaning,
      '3. ' + questionTemplate.threeMeaning
    ]);
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => BackDialogAlert(),
    );
  }

  Widget displayCongrats() {
    if (questionNr > 1) {
      return Column(children: [
        Text(
          YOUR_RESULT + agreedScore,
          style: TextStyle(fontSize: fontMedium, fontWeight: FontWeight.bold),
        ),
      ]);
    } else {
      return Column(children: [
        Text(
          CONGRATS,
          style: TextStyle(fontSize: fontMedium, fontWeight: FontWeight.bold),
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              GREAT_MINDS,
              style: TextStyle(fontSize: fontMedium),
            )),
      ]);
    }
  }

  Widget buildCongratulations() {
    return Container(
      padding: EdgeInsets.all(12.0),
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 12, bottom: 24), child: displayCongrats()),
          Container(
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: BarChart.withSampleData(scoreMeanings, questionByNumber.topicName, int.parse(agreedScore)))),
        ],
      ),
    );
  }

  Widget buildNoData() {
    return Padding(
      padding: EdgeInsets.only(bottom: 25.0),
      child: Text(
        NO_SCORES_TO_DISPLAY,
        style: TextStyle(fontSize: fontMedium),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      Wakelock.enable();
    });
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
        appBar: AppBar(title: AgileWithBackIconButton(_onBackPressed), automaticallyImplyLeading: false),
        body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Column(
      children: [
        LinearProgressIndicator(
          value: questionNr / NUMBER_OF_GAME_QUESTIONS,
        ),
        Row(children: [GamePin(gamePin: gamePin)]),
        if (agreedScore != null) buildCongratulations(),
        if (agreedScore == null) buildNoData(),
        if (role == Role.HOST)
          Row(
            children: [
              Expanded(
                child: Container(
                  child: PlayButton(
                    onPressed: () async {
                      if (_firstPress) {
                        _firstPress = false;
                        if (questionNr == NUMBER_OF_GAME_QUESTIONS) {
                          await gameService.changeGameState(gameRef, GameState.FINAL);
                          _log.info('${participantRef} HOST changed gameState to: ${GameState.FINAL}');
                          return Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) {
                              gameService.changeGameKeepState(gameRef, false);
                              mixpanel.track('congratulations_page: pause workshop');
                              return FinalPage(participantRef, gameRef);
                            }),
                          );
                        }
                        await gameService.changeGameState(gameRef, '${GameState.QUESTION}_${questionNr + 1}');
                        _log.info(
                            '${participantRef} HOST changed gameState to: ${GameState.QUESTION}_${questionNr + 1}');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) {
                            gameService.changeGameKeepState(gameRef, false);
                            return GameQuestionPage(questionNr + 1, participantRef, gameRef);
                          }),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        if (role == Role.HOST)
          Row(
          children: [
            Expanded(
                child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                        padding: EdgeInsets.all(25),
                        child: AgileButton(
                            onPressed: () async {
                              gameService.changeGameKeepState(gameRef, true);
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return SimpleDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                                    elevation: 16,
                                    children: [
                                      Container(
                                        height: 200.0,
                                        width: 360.0,
                                        child: Column(
                                          children: [
                                            Center(
                                              child: Text(
                                                PAUSE_TEXT,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: fontMedium),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SimpleDialogOption(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Center(
                                            child: Text(
                                              CLOSE,
                                              style: TextStyle(fontSize: fontMedium, color: accentColor),
                                            ),
                                          ))
                                    ],
                                  );
                                },
                              );
                            },
                            buttonTitle: GAME_PAUSE_BUTTON))))
          ],
        )
      ],
    )));
  }
}
