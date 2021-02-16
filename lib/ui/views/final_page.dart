import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:superagile_app/entities/question_template.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/mailing_service.dart';
import 'package:superagile_app/services/participant_service.dart';
import 'package:superagile_app/services/question_service.dart';
import 'package:superagile_app/services/score_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/game_pin.dart';
import 'package:superagile_app/ui/components/superagile_wheel.dart';
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
  MailingService mailingService = MailingService();
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
    questions.sort((a, b) => (int.parse(a.reference.id)).compareTo(int.parse(b.reference.id)));
    var features = questions.map((e) => e.topicNameShort).toList();
    var data = agreedScores.values.toList();

    return Column(
      children: [
        Row(children: [GamePin(gamePin: gamePin)]),
        Expanded(
            child: SingleChildScrollView(
                child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 10, top: 10),
              child: Text('${OVERALL_SCORE}: ${calculateOverallScore()}',
                  style: TextStyle(color: Colors.yellow, fontSize: 18, letterSpacing: 1.5),
                  textAlign: TextAlign.center),
            ),
          ],
        ))),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SuperagileWheel(
                features: features,
                data: data,
              ),
            ],
          ),
        ),
        Row(
          children: [
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(hintText: EMAIL_FIELD_HINT_TEXT),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Flexible(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: AgileButton(
                    buttonTitle: EMAIL_ACTION_BUTTON,
                    onPressed: () {
                      mailingService.sendResults(_emailController.text, agreedScores);
                    }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String calculateOverallScore() {
    if (agreedScores.values.contains(null)) {
      return NO_SCORE;
    }
    return agreedScores.values.reduce((sum, value) => sum + value).toString();
  }
}
