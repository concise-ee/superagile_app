import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:superagile_app/entities/question.dart';
import 'package:superagile_app/entities/score.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/question_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
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
  final QuestionService _questionService = QuestionService();
  final GameService _gameService = GameService();
  final int questionNr;
  final DocumentReference playerRef;
  final DocumentReference gameRef;
  Question question;

  _GameQuestionPage(this.questionNr, this.playerRef, this.gameRef);

  @override
  void setState(state) {
    if (mounted) {
      super.setState(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    loadQuestionContentByNumber();
    return Scaffold(
      appBar: AppBar(title: Text(HASH_SUPERAGILE)),
      body: _buildBody(context),
    );
  }

  void loadQuestionContentByNumber() async {
    final Question questionByNumber = await _questionService.findQuestionByNumber(questionNr);
    setState(() {
      question = questionByNumber;
    });
  }

  void saveScore(String buttonValue) async {
    await _gameService.addScore(playerRef, Score(questionNr, int.parse(buttonValue)));
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return GameQuestionPage(questionNr + 1, playerRef, gameRef);
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
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
                                  question != null ? question.question : '',
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
                                question != null ? question.zeroMeaning : '',
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
                                question != null ? question.oneMeaning : '',
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
                                question != null ? question.twoMeaning : '',
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
                                question != null ? question.threeMeaning : '',
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
                                question != null ? question.shortDesc : '',
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
                              question != null ? question.longDesc : '',
                              style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.5),
                            )),
                      ),
                    ),
                  ],
                ))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: AgileButton(
                buttonTitle: ZERO,
                onPressed: () async {
                  saveScore(ZERO);
                },
              ),
            ),
            Expanded(
              child: AgileButton(
                buttonTitle: ONE,
                onPressed: () async {
                  saveScore(ONE);
                },
              ),
            ),
            Expanded(
              child: AgileButton(
                buttonTitle: TWO,
                onPressed: () async {
                  saveScore(TWO);
                },
              ),
            ),
            Expanded(
              child: AgileButton(
                buttonTitle: THREE,
                onPressed: () async {
                  saveScore(THREE);
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
