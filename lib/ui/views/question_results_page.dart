import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/question_answers_section.dart';
import 'package:superagile_app/ui/views/congratulations_page.dart';
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
  QuestionScores questionScores = new QuestionScores([], [], [], []);
  final int questionNr;
  final DocumentReference playerRef;
  final DocumentReference gameRef;

  _QuestionResultsPageState(this.questionNr, this.playerRef, this.gameRef) {
    loadQuestionScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(HASH_SUPERAGILE)),
        body: Column(
          children: [
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
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              height: 160.0,
              child: Column(
                children: [
                  Text(areVotedScoresSame() ? '' : SAME_ANSWER, textAlign: TextAlign.center),
                  Spacer(flex: 1),
                  buildBackOrNextButton()
                ],
              ),
            )
          ],
        ));
  }

  void loadQuestionScores() async {
    var scores = await gameService.findScoresForQuestion(this.gameRef, this.questionNr);
    setState(() {
      questionScores = scores;
    });
  }

  Widget buildBackOrNextButton() {
    if (areVotedScoresSame()) {
      return AgileButton(
        buttonTitle: CONTINUE,
        onPressed: () {
          Navigator.push(
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
        Navigator.push(
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
}
