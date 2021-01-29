import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
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
    String username = 'noreply@concise.ee';
    String password = 'vhuveuqwywtubdik';

    final smtpServer = gmail(username, password);

    //Create our Message
    final message = Message()
      ..from = Address(username, 'concise')
      ..recipients.add(_emailController.text)
      ..subject = 'Flutter Mailer Test'
      ..text = 'Auto Mailing with Flutter with Custom Template';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
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
              activityTimer.cancel();
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
