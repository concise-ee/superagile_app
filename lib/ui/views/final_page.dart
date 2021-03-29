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
import 'package:superagile_app/services/timer_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/agile_with_back_icon_button.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/game_pin.dart';
import 'package:superagile_app/ui/components/rounded_text_form_field.dart';
import 'package:superagile_app/ui/components/social_media_icons.dart';
import 'package:superagile_app/ui/components/superagile_wheel.dart';
import 'package:superagile_app/ui/views/start_page.dart';
import 'package:superagile_app/utils/global_theme.dart';
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
  TimerService timerService = TimerService();
  Map<String, int> agreedScores;
  bool isLoading = true;
  bool isMailSending = false;
  bool isMailSent = false;
  int gamePin;
  List<QuestionTemplate> questions;
  final _formKey = GlobalKey<FormState>();

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
    questionTemplates.sort((a, b) => (int.parse(a.reference.id)).compareTo(int.parse(b.reference.id)));
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
        appBar: AppBar(title: AgileWithBackIconButton(_onBackPressed), automaticallyImplyLeading: false),
        body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    if (agreedScores.containsValue(null)) {
      return renderNoScores();
    }
    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(children: [GamePin(gamePin: gamePin)]),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SuperagileWheel(
                      topics: questions.map((e) => e.topicNameShort).toList(),
                      scores: agreedScores.values.toList(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      child: Text(
                        isMailSent ? EMAIL_SENT : INSERT_EMAIL_TO_GET_RESULTS,
                        style: TextStyle(fontSize: fontSmall),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      child: RoundedTextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        hintText: EMAIL_FIELD_HINT_TEXT,
                        validator: (value) {
                          if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                            setState(() {
                              isMailSent = false;
                            });
                            return PLEASE_ENTER_VALID_EMAIL;
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      child: renderSendEmail(),
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 10), child: SocialMediaIcons()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          fit: FlexFit.loose,
                          flex: 1,
                          child: Container(
                            alignment: Alignment.center,
                            child: Padding(
                                padding: EdgeInsets.all(25),
                                child: Text(HAVE_SUGGESTIONS_OR_QUESTIONS,
                                    style: TextStyle(color: white, fontSize: fontSmall), textAlign: TextAlign.center)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget renderSendEmail() {
    return !isMailSending
        ? AgileButton(
            buttonTitle: EMAIL_ACTION_BUTTON,
            onPressed: () async {
              if (_formKey.currentState.validate()) {
                setState(() => isMailSending = true);
                await mailingService.sendResults(_emailController.text, agreedScores, calculateOverallScore());
                setState(() {
                  isMailSending = false;
                  isMailSent = true;
                });
              }
            })
        : SizedBox(height: 80, width: 80, child: CircularProgressIndicator());
  }

  Widget renderNoScores() {
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 25.0),
              child: Text(
                NO_SCORES_TO_DISPLAY,
                style: TextStyle(fontSize: fontMedium),
                textAlign: TextAlign.center,
              ),
            ),
            AgileButton(
                buttonTitle: BACK_TO_START,
                onPressed: () {
                  timerService.cancelActivityTimer();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return StartPage();
                    }),
                  );
                }),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: SocialMediaIcons(),
            ),
          ],
        ),
      ),
    );
  }

  String calculateOverallScore() {
    if (agreedScores.values.contains(null)) {
      return NO_SCORE;
    }
    return agreedScores.values.reduce((sum, value) => sum + value).toString();
  }
}
