import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/entities/role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/participant_service.dart';
import 'package:superagile_app/services/score_service.dart';
import 'package:superagile_app/services/timer_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/game_pin.dart';
import 'package:superagile_app/ui/components/question_answers_section.dart';
import 'package:superagile_app/ui/views/congratulations_page.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/labels.dart';

import 'game_question_page.dart';

final _log = Logger((QuestionResultsPage).toString());

class QuestionResultsPage extends StatefulWidget {
  final int questionNr;
  final DocumentReference gameRef;
  final DocumentReference participantRef;

  QuestionResultsPage({@required this.questionNr, @required this.participantRef, @required this.gameRef});

  @override
  _QuestionResultsPageState createState() =>
      _QuestionResultsPageState(this.questionNr, this.participantRef, this.gameRef);
}

class _QuestionResultsPageState extends State<QuestionResultsPage> {
  final GameService gameService = GameService();
  final ParticipantService participantService = ParticipantService();
  final ScoreService scoreService = ScoreService();
  final TimerService timerService = TimerService();
  QuestionScores questionScores = QuestionScores([], [], [], [], []);
  final int questionNr;
  final DocumentReference participantRef;
  final DocumentReference gameRef;
  StreamSubscription<DocumentSnapshot> gameStream;
  Role role;
  bool isLoading = true;
  int gamePin;

  _QuestionResultsPageState(this.questionNr, this.participantRef, this.gameRef);

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
    if (mounted && role == Role.PLAYER) {
      listenForUpdateToSwitchPage();
    }
  }

  void listenForUpdateToSwitchPage() async {
    gameStream = gameService.getGameStream(gameRef).listen((data) async {
      String gameState = await gameService.getGameState(gameRef);
      int newQuestionNr = parseSequenceNumberFromGameState(gameState);
      if (gameState.contains(GameState.QUESTION)) {
        if (newQuestionNr == questionNr) {
          await scoreService.deleteOldScore(participantRef, questionNr);
        }
        _log.info('${participantRef} navigates to GameQuestionPage, newQuestionNr: ${newQuestionNr}');
        return Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return GameQuestionPage(newQuestionNr, participantRef, gameRef);
          }),
        );
      } else if (gameState.contains(GameState.CONGRATULATIONS)) {
        _log.info('${participantRef} navigates to CongratulationsPage, newQuestionNr: ${newQuestionNr}');
        return Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return CongratulationsPage(newQuestionNr, participantRef, gameRef);
          }),
        );
      }
    });
  }

  Future<void> loadData() async {
    Participant participant = await participantService.findGameParticipantByRef(participantRef);
    var scores = await scoreService.findScoresForQuestion(this.gameRef, this.questionNr);
    var pin = await gameService.getGamePinByRef(gameRef);
    setState(() {
      role = participant.role;
      questionScores = scores;
      isLoading = false;
      gamePin = pin;
    });
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
            body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context)));
  }

  Widget buildBody(context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: questionNr / NUMBER_OF_GAME_QUESTIONS,
        ),
        Row(children: [GamePin(gamePin: gamePin)]),
        Expanded(
            child: SingleChildScrollView(
                child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuestionAnswersSection(answerNumber: 3, participantNames: questionScores.answered3),
            QuestionAnswersSection(answerNumber: 2, participantNames: questionScores.answered2),
            QuestionAnswersSection(answerNumber: 1, participantNames: questionScores.answered1),
            QuestionAnswersSection(answerNumber: 0, participantNames: questionScores.answered0),
          ],
        ))),
        if (role == Role.HOST) buildHostContainer() else buildParticipantContainer()
      ],
    );
  }

  Container buildHostContainer() {
    return Container(
      padding: EdgeInsets.all(25),
      height: !areVotedScoresSame() ? 180 : 130,
      child: Column(
        children: [
          if (!areVotedScoresSame()) ...[
            Text(SAME_ANSWER, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
            Spacer(flex: 1),
          ],
          buildBackOrNextButton()
        ],
      ),
    );
  }

  Container buildParticipantContainer() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      height: !areVotedScoresSame() ? 80 : 0,
      child: Column(
        children: [
          Text(SAME_ANSWER, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget buildBackOrNextButton() {
    if (areVotedScoresSame()) {
      return AgileButton(
        buttonTitle: CONTINUE,
        onPressed: () async {
          await scoreService.setAgreedScore(gameRef, getAgreedScore(), questionNr);
          await gameService.changeGameState(gameRef, '${GameState.CONGRATULATIONS}_$questionNr');
          _log.info('${participantRef} HOST changed gameState to: ${GameState.CONGRATULATIONS}_$questionNr');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) {
              return CongratulationsPage(this.questionNr, this.participantRef, this.gameRef);
            }),
          );
        },
      );
    }
    return AgileButton(
      buttonTitle: CHANGE_ANSWER,
      onPressed: () async {
        await gameService.changeGameState(gameRef, '${GameState.QUESTION}_$questionNr');
        await scoreService.deleteOldScore(participantRef, questionNr);
        _log.info('${participantRef} HOST changed gameState to: ${GameState.QUESTION}_$questionNr');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return GameQuestionPage(this.questionNr, this.participantRef, this.gameRef);
          }),
        );
      },
    );
  }

  bool areVotedScoresSame() {
    int numberOfParticipantsAnswered = questionScores.answered0.length +
        questionScores.answered1.length +
        questionScores.answered2.length +
        questionScores.answered3.length;
    if (questionScores.answered0.length == numberOfParticipantsAnswered ||
        questionScores.answered1.length == numberOfParticipantsAnswered ||
        questionScores.answered2.length == numberOfParticipantsAnswered ||
        questionScores.answered3.length == numberOfParticipantsAnswered) {
      return true;
    }
    return false;
  }

  int getAgreedScore() {
    if (questionScores.answered0.isNotEmpty) return 0;
    if (questionScores.answered1.isNotEmpty) return 1;
    if (questionScores.answered2.isNotEmpty) return 2;
    if (questionScores.answered3.isNotEmpty) return 3;
    if (questionScores.answeredNull.isNotEmpty) return null;
    throw ('No agreed score found.');
  }
}
