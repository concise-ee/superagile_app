import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/question_scores.dart';
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
import 'package:superagile_app/ui/views/question_results_page.dart';
import 'package:superagile_app/utils/game_state_router.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';

import 'final_page.dart';

final _log = Logger((GameQuestionPage).toString());

class GameQuestionPage extends StatefulWidget {
  final int _questionNr;
  final DocumentReference _participantRef;
  final DocumentReference _gameRef;

  GameQuestionPage(this._questionNr, this._participantRef, this._gameRef);

  @override
  _GameQuestionPage createState() =>
      _GameQuestionPage(this._questionNr, this._participantRef, this._gameRef);
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
  StreamSubscription<DocumentSnapshot> gameStream;
  Role role;
  bool isPlayingAlong;
  bool isLoading = true;
  int gamePin;
  List<String> answeredParticipantNames = [];
  List<Participant> activeParticipants = [];
  final ValueNotifier<double> percentage = ValueNotifier<double>(0.0);

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
    gameStream?.cancel();
    super.dispose();
  }

  void loadDataAndSetupListeners() async {
    await loadData();
    listenForUpdateToGoToQuestionResultsPage();
  }

  Future<void> loadData() async {
    Participant participant =
        await participantService.findGameParticipantByRef(participantRef);
    final QuestionTemplate questionByNumber =
        await questionService.findQuestionByNumber(questionNr);
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
      List<Participant> activeParticipants =
          await participantService.findActiveGameParticipants(gameRef);
      QuestionScores questionScores =
          await scoreService.findScoresForQuestion(gameRef, questionNr);
      List<String> answeredParticipantNames =
          scoreService.getAnsweredParticipantNames(questionScores);
      setState(() {
        this.activeParticipants = activeParticipants;
        this.answeredParticipantNames = answeredParticipantNames;
      });
      percentage.value = participantService.calculateCircleFill(
          activeParticipants, answeredParticipantNames);
      if (gameState.contains(GameState.QUESTION_RESULTS)) {
        return navigateToQuestionResultsPage();
      } else if (gameState == GameState.FINAL) {
        _log.info(
            '${participantRef} navigates to FinalPage, gameState: ${gameState}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return FinalPage(participantRef, gameRef);
          }),
        );
      }
    });
  }

  void listenEveryActiveParticipantScoreChanges() async {
    gameStream = gameService.getGameStream(gameRef).listen((data) async {
      List<Participant> activeParticipants =
          await participantService.findActiveGameParticipants(gameRef);
      QuestionScores questionScores =
          await scoreService.findScoresForQuestion(gameRef, questionNr);
      List<String> answeredParticipantNames =
          scoreService.getAnsweredParticipantNames(questionScores);
      setState(() {
        this.activeParticipants = activeParticipants;
        this.answeredParticipantNames = answeredParticipantNames;
      });
      percentage.value = participantService.calculateCircleFill(
          activeParticipants, answeredParticipantNames);

      bool haveAllActiveParticipantsVoted = true;
      if (activeParticipants.isEmpty) {
        return false;
      }
      for (var activeParticipant in activeParticipants) {
        if (!answeredParticipantNames.contains(activeParticipant.name)) {
          haveAllActiveParticipantsVoted = false;
        }
      }
      if (haveAllActiveParticipantsVoted) {
        gameStream.cancel();
        await gameService.changeGameState(
            gameRef, '${GameState.QUESTION_RESULTS}_$questionNr');
        return navigateToQuestionResultsPage();
      }
    });
  }

  Future<MaterialPageRoute<QuestionResultsPage>>
      navigateToQuestionResultsPage() {
    _log.info(
        '${participantRef} navigates to QuestionResultsPage, questionNr: ${questionNr}');
    return Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) {
      return QuestionResultsPage(
          questionNr: questionNr,
          gameRef: gameRef,
          participantRef: participantRef);
    }), (Route<dynamic> route) => false);
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
          appBar: AppBar(
              title: AgileWithBackIconButton(_onBackPressed),
              automaticallyImplyLeading: false,
              actions: [buildParticipantsDialog()]),
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : buildBody(context),
        ));
  }

  Widget buildParticipantsDialog() {
    return FlatButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                elevation: 16,
                children: [
                  Container(
                    height: 400.0,
                    width: 360.0,
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            ANSWERED,
                            style: TextStyle(fontSize: fontMedium),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: (Column(
                              children: [
                                buildParticipantsList(),
                              ],
                            )),
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
                          style: TextStyle(
                              fontSize: fontMedium, color: accentColor),
                        ),
                      ))
                ],
              );
            },
          );
        },
        child: CircularPercentIndicator(
          radius: 30.0,
          lineWidth: 5.0,
          percent: percentage.value,
          progressColor: accentColor,
          backgroundColor: secondaryColor,
        ));
  }

  Widget buildParticipantsList() {
    return Column(
      children: <Widget>[
        ValueListenableBuilder(
          builder: (BuildContext context, double value, Widget child) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: activeParticipants.length,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    activeParticipants[index].name,
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: Icon(renderIcon(activeParticipants[index].name)),
                );
              },
            );
          },
          valueListenable: percentage,
        )
      ],
    );
  }

  IconData renderIcon(String participantName) {
    if (answeredParticipantNames == null) return null;
    return answeredParticipantNames.contains(participantName)
        ? Icons.check
        : null;
  }

  void saveScoreAndWaitForNextPage(String scoreValue) async {
    await scoreService.setScore(
        participantRef, gameRef, questionNr, scoreValue);
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
                padding: EdgeInsets.only(left: 25, right: 25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                            fit: FlexFit.tight,
                            flex: 6,
                            child: Container(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: EdgeInsets.only(right: 10),
                                  child: Text(
                                    questionNr.toString(),
                                    style: TextStyle(
                                        fontSize: fontExtraExtraLarge),
                                  )),
                            )),
                        Expanded(
                          flex: 8,
                          child: Container(
                              child: Text(
                            questionTemplate.question,
                            style: TextStyle(fontSize: fontMedium),
                          )),
                        ),
                      ],
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 1,
                      child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            questionTemplate.shortDesc,
                            style: TextStyle(fontSize: fontSmall),
                            textAlign: TextAlign.center,
                          )),
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
                              style: TextStyle(fontSize: fontSmall),
                            )),
                      ),
                    ),
                  ],
                ))),
        if (role == Role.PLAYER || (role == Role.HOST && isPlayingAlong))
          SafeArea(
              child: Row(
            children: [
              renderScoreButton(ZERO, questionTemplate.zeroMeaning),
              renderScoreButton(ONE, questionTemplate.oneMeaning),
              renderScoreButton(TWO, questionTemplate.twoMeaning),
              renderScoreButton(THREE, questionTemplate.threeMeaning)
            ],
          ))
        else
          SafeArea(child: Row(children: [renderContinueButton()]))
      ],
    );
  }

  Expanded renderScoreButton(String value, String meaning) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: secondaryColor, width: 5),
          ),
        ),
        child: RaisedButton(
          elevation: 0,
          hoverElevation: 0,
          focusElevation: 0,
          highlightElevation: 0,
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      color: value == pressedButton.toString()
                          ? primaryColor
                          : accentColor,
                      fontSize: fontExtraLarge)),
              Text(meaning,
                  style: TextStyle(
                      color: value == pressedButton.toString()
                          ? primaryColor
                          : accentColor,
                      fontSize: fontExtraSmall),
                  textAlign: TextAlign.center),
            ],
          ),
          color: value == pressedButton.toString() ? accentColor : primaryColor,
          onPressed: () {
            setState(() => pressedButton = int.parse(value));
            saveScoreAndWaitForNextPage(value);
          },
        ),
      ),
    );
  }

  Expanded renderContinueButton() {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: secondaryColor, width: 5),
          ),
        ),
        child: RaisedButton(
          child: Text(
            CONTINUE,
            style: TextStyle(
                color: pressedButton == HOST_SKIP_VALUE
                    ? primaryColor
                    : accentColor,
                fontSize: fontExtraLarge),
          ),
          color: pressedButton == HOST_SKIP_VALUE ? accentColor : primaryColor,
          onPressed: () {
            setState(() => pressedButton = HOST_SKIP_VALUE);
            saveScoreAndWaitForNextPage(null);
          },
        ),
      ),
    );
  }
}
