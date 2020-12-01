import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/question_answers_section.dart';
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
  final GameService _gameService = GameService();
  QuestionScores _questionScores = new QuestionScores([], [], [], []);
  final int _questionNr;
  final DocumentReference _playerRef;
  final DocumentReference _gameRef;

  _QuestionResultsPageState(this._questionNr, this._playerRef, this._gameRef) {
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
                QuestionAnswersSection(answerNumber: 3, playerNames: _questionScores.answered3),
                QuestionAnswersSection(answerNumber: 2, playerNames: _questionScores.answered2),
                QuestionAnswersSection(answerNumber: 1, playerNames: _questionScores.answered1),
                QuestionAnswersSection(answerNumber: 0, playerNames: _questionScores.answered0),
              ],
            ))),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              height: 160.0,
              child: Column(
                children: [
                  Text(SAME_ANSWER, textAlign: TextAlign.center),
                  Spacer(flex: 1),
                  AgileButton(
                    buttonTitle: CHANGE_ANSWER,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return GameQuestionPage(this._questionNr + 1, this._playerRef, this._gameRef);
                        }),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }

  void loadQuestionScores() async {
    var scores = await _gameService.findScoresForQuestion(this._gameRef, this._questionNr);
    setState(() {
      _questionScores = scores;
    });
  }

}
