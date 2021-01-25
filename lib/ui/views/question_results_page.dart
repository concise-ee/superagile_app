import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/entities/user_role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/player_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/game_pin.dart';
import 'package:superagile_app/ui/components/question_answers_section.dart';
import 'package:superagile_app/ui/views/congratulations_page.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/labels.dart';

import 'game_question_page.dart';

class QuestionResultsPage extends StatefulWidget {
  final int questionNr;
  final DocumentReference gameRef;
  final DocumentReference playerRef;

  QuestionResultsPage({@required this.questionNr, @required this.playerRef, @required this.gameRef});

  @override
  _QuestionResultsPageState createState() => _QuestionResultsPageState(this.questionNr, this.playerRef, this.gameRef);
}

class _QuestionResultsPageState extends State<QuestionResultsPage> {
  final GameService gameService = GameService();
  final PlayerService playerService = PlayerService();
  QuestionScores questionScores = new QuestionScores([], [], [], [], []);
  final int questionNr;
  final DocumentReference playerRef;
  final DocumentReference gameRef;
  StreamSubscription<DocumentSnapshot> gameStream;
  UserRole userRole;
  bool isLoading = true;
  int gamePin;

  _QuestionResultsPageState(this.questionNr, this.playerRef, this.gameRef);

  @override
  void setState(state) {
    if (mounted) {
      super.setState(state);
    }
  }

  @override
  void initState() {
    super.initState();
    loadDataAndSetupListener();
  }

  @override
  void dispose() {
    if (gameStream != null) {
      gameStream.cancel();
    }
    super.dispose();
  }

  void loadDataAndSetupListener() async {
    await loadData();
    if (mounted) {
      listenForUpdateToSwitchPage();
    }
  }

  void listenForUpdateToSwitchPage() async {
    gameStream = gameService.getGameStream(gameRef).listen((data) async {
      String gameState = await gameService.getGameState(gameRef);
      int newQuestionNr = parseSequenceNumberFromGameState(gameState);
      if (userRole == UserRole.PLAYER && gameState.contains(GameState.QUESTION)) {
        await gameService.deleteOldScore(playerRef, questionNr);
        return Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return GameQuestionPage(newQuestionNr, playerRef, gameRef);
          }),
        );
      } else if (userRole == UserRole.PLAYER && gameState.contains(GameState.CONGRATULATIONS)) {
        return Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return CongratulationsPage(newQuestionNr, playerRef, gameRef);
          }),
        );
      }
    });
  }

  Future<void> loadData() async {
    Player player = await playerService.findGamePlayerByRef(playerRef);
    var scores = await gameService.findScoresForQuestion(this.gameRef, this.questionNr);
    var pin = await gameService.getGamePinByRef(gameRef);
    setState(() {
      userRole = player.role;
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
    return new WillPopScope(
        onWillPop: () => _onBackPressed(),
        child: Scaffold(
            appBar: AppBar(title: Text(HASH_SUPERAGILE), automaticallyImplyLeading: false),
            body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context)));
  }

  Widget buildBody(context) {
    return Column(
      children: [
        Row(children: [GamePin(gamePin: this.gamePin)]),
        Expanded(
            child: SingleChildScrollView(
                child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QuestionAnswersSection(answerNumber: 3, playerNames: questionScores.answered3),
            QuestionAnswersSection(answerNumber: 2, playerNames: questionScores.answered2),
            QuestionAnswersSection(answerNumber: 1, playerNames: questionScores.answered1),
            QuestionAnswersSection(answerNumber: 0, playerNames: questionScores.answered0),
          ],
        ))),
        if (userRole == UserRole.HOST) buildHostContainer() else buildPlayerContainer()
      ],
    );
  }

  Container buildHostContainer() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      height: !areVotedScoresSame() ? 160 : 100,
      child: Column(
        children: [
          if (!areVotedScoresSame()) ...[
            Text(SAME_ANSWER, textAlign: TextAlign.center),
            Spacer(flex: 1),
          ],
          buildBackOrNextButton()
        ],
      ),
    );
  }

  Container buildPlayerContainer() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      height: !areVotedScoresSame() ? 80 : 0,
      child: Column(
        children: [
          Text(SAME_ANSWER, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget buildBackOrNextButton() {
    if (areVotedScoresSame()) {
      return AgileButton(
        buttonTitle: CONTINUE,
        onPressed: () async {
          await gameService.setAgreedScore(gameRef, getAgreedScore(), questionNr);
          await gameService.changeGameState(gameRef, '${GameState.CONGRATULATIONS}_$questionNr');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) {
              return CongratulationsPage(this.questionNr, this.playerRef, this.gameRef);
            }),
          );
        },
      );
    }
    return AgileButton(
      buttonTitle: CHANGE_ANSWER,
      onPressed: () async {
        await gameService.deleteOldScore(playerRef, questionNr);
        await gameService.changeGameState(gameRef, '${GameState.QUESTION}_$questionNr');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return GameQuestionPage(this.questionNr, this.playerRef, this.gameRef);
          }),
        );
      },
    );
  }

  bool areVotedScoresSame() {
    int numberOfPlayersAnswered = questionScores.answered0.length +
        questionScores.answered1.length +
        questionScores.answered2.length +
        questionScores.answered3.length;
    if (questionScores.answered0.length == numberOfPlayersAnswered ||
        questionScores.answered1.length == numberOfPlayersAnswered ||
        questionScores.answered2.length == numberOfPlayersAnswered ||
        questionScores.answered3.length == numberOfPlayersAnswered) {
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
