import 'dart:async';
import 'dart:convert' as convert;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:http/http.dart' as http;
import 'package:superagile_app/entities/question_template.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/participant_service.dart';
import 'package:superagile_app/services/question_service.dart';
import 'package:superagile_app/services/score_service.dart';
import 'package:superagile_app/services/timer_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/game_pin.dart';
import 'package:superagile_app/ui/views/start_page.dart';
import 'package:superagile_app/utils/labels.dart';

class FinalPage extends StatefulWidget {
  final DocumentReference _participantRef;
  final DocumentReference _gameRef;

  FinalPage(this._participantRef, this._gameRef);

  @override
  _FinalPage createState() => _FinalPage(this._participantRef, this._gameRef);
}

class _FinalPage extends State<FinalPage> {
  final DocumentReference participantRef;
  final DocumentReference gameRef;
  final _emailController = TextEditingController();
  final GameService gameService = GameService();
  final ParticipantService participantService = ParticipantService();
  final QuestionService questionService = QuestionService();
  final ScoreService scoreService = ScoreService();
  final TimerService timerService = TimerService();
  Map<String, int> agreedScores;
  bool isLoading = true;
  int gamePin;
  List<QuestionTemplate> questions;

  _FinalPage(this.participantRef, this.gameRef);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void Mailer() async {
    List<String> subScores = new List();
    for (MapEntry<String, int> score in agreedScores.entries) {
      subScores.add(score.value.toString());
    }
    ;
    Map<String, dynamic> formMap = {
      'email': _emailController.text,
      'final_score': '${calculateOverallScore()}',
      'sub_1': subScores[0],
      'sub_2': subScores[1],
      'sub_3': subScores[2],
      'sub_4': subScores[3],
      'sub_5': subScores[4],
      'sub_6': subScores[5],
      'sub_7': subScores[6],
      'sub_8': subScores[7],
      'sub_9': subScores[8],
      'sub_10': subScores[9],
      'sub_11': subScores[10],
      'sub_12': subScores[11],
      'sub_13': subScores[12],
    };
    print(formMap);
    await http.post(
        'https://script.google.com/macros/s/AKfycbyQXnLhyn1pMN4Rq0NodnfUO_r0l3GhiI6VOh15PDGngrOBzDoEzPcskw/exec',
        headers: <String, String>{'Content-Type': 'application/x-www-form-urlencoded'},
        body: convert.jsonEncode(formMap),
        encoding: convert.Encoding.getByName('utf-8'));
  }

  void loadData() async {
    var totalScore = await scoreService.getAgreedScores(gameRef);
    var pin = await gameService.getGamePinByRef(gameRef);
    var questionTemplates = await questionService.getAllQuestionTemplates();
    setState(() {
      agreedScores = totalScore;
      isLoading = false;
      gamePin = pin;
      questions = questionTemplates;
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
        body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Row(children: [GamePin(gamePin: gamePin)]),
        Expanded(
            child: SingleChildScrollView(
                child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 20, top: 20),
              child: Text('${OVERALL_SCORE}: ${calculateOverallScore()}',
                  style: TextStyle(color: Colors.yellow, fontSize: 24, letterSpacing: 1.5),
                  textAlign: TextAlign.center),
            ),
            buildSeparateScore(),
          ],
        ))),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: 'Enter Email'),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: AgileButton(
                  buttonTitle: 'Send results',
                  onPressed: Mailer,
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.only(bottom: 5),
          child: AgileButton(
            onPressed: () {
              timerService.cancelActivityTimer();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return StartPage();
                }),
              );
            },
            buttonTitle: BACK_TO_BEGINNING,
          ),
        )
      ],
    );
  }

  String calculateOverallScore() {
    if (agreedScores.values.contains(null)) {
      return NO_SCORE;
    }
    return agreedScores.values.reduce((sum, value) => sum + value).toString();
  }

  Widget buildSeparateScore() {
    return Column(children: [
      for (MapEntry<String, int> score in agreedScores.entries)
        Container(
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Text('${questions.firstWhere((element) => element.reference.id == score.key).topicName}: ${score.value}',
                style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 1.5), textAlign: TextAlign.center)
          ]),
        ),
    ]);
  }
}
