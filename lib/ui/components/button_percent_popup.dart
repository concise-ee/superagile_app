import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/participant_service.dart';
import 'package:superagile_app/services/score_service.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/utils/list_utils.dart';

class ButtonPercentPopup extends StatefulWidget {
  final DocumentReference _participantRef;
  final DocumentReference _gameRef;
  final int _questionNr;

  ButtonPercentPopup(this._participantRef, this._gameRef, this._questionNr);

  @override
  _ButtonPercentPopupState createState() =>
      _ButtonPercentPopupState(this._participantRef, this._gameRef, this._questionNr);
}

class _ButtonPercentPopupState extends State<ButtonPercentPopup> {
  final participantService = ParticipantService();
  final gameService = GameService();
  final scoreService = ScoreService();
  final DocumentReference participantRef;
  final DocumentReference gameRef;
  final int questionNr;
  StreamSubscription<QuerySnapshot> participantsStream;
  List<StreamSubscription<QuerySnapshot>> participantScoreStreams = [];
  List<Participant> activeParticipants;
  QuestionScores questionScores;
  final percentage = ValueNotifier<double>(0.0);

  _ButtonPercentPopupState(this.participantRef, this.gameRef, this.questionNr);

  @override
  void setState(state) {
    if (mounted) {
      super.setState(state);
    }
  }

  @override
  void initState() {
    super.initState();
    participantsStream = participantService.getParticipantsStream(gameRef).listen((data) async {
      listenEveryActiveParticipantScoreChanges();
    });
  }

  void listenEveryActiveParticipantScoreChanges() async {
    var activeParticipantsList = await participantService.findActiveGameParticipants(gameRef);
    setState(() => activeParticipants = activeParticipantsList);
    setupActiveParticipantsScoreStreams();
    participantsStream = participantService.getParticipantsStream(gameRef).listen((data) async {
      List<Participant> newActiveParticipants = await participantService.findActiveGameParticipants(gameRef);
      if (!areEqualByName(activeParticipants, newActiveParticipants)) {
        cancelParticipantsScoreStreams();
        setState(() => activeParticipants = newActiveParticipants);
        setupActiveParticipantsScoreStreams();
      }
    });
  }

  void setupActiveParticipantsScoreStreams() {
    for (var participant in activeParticipants) {
      StreamSubscription<QuerySnapshot> stream =
          scoreService.getScoresStream(participant.reference).listen((data) async {
        var questionScores = await scoreService.findScoresForQuestion(gameRef, questionNr);
        setState(() => this.questionScores = questionScores);
        percentage.value = calculateCircleFill();
      });
      participantScoreStreams.add(stream);
    }
  }

  void cancelParticipantsScoreStreams() {
    participantScoreStreams.forEach((stream) => stream.cancel());
    participantScoreStreams.clear();
  }

  @override
  void dispose() {
    cancelParticipantsScoreStreams();
    participantsStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FittedBox(
        fit: BoxFit.fitWidth,
        child: FlatButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                    elevation: 16,
                    children: [
                      Container(
                        height: 400.0,
                        width: 360.0,
                        child: ListView(
                          children: <Widget>[
                            Center(
                              child: Text(
                                ANSWERED,
                                style: TextStyle(fontSize: 24, color: accentColor),
                              ),
                            ),
                            buildActiveParticipantsWidget(),
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
                              style: TextStyle(fontSize: 24, color: accentColor),
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
              backgroundColor: Colors.black,
            )));
  }

  Widget buildActiveParticipantsWidget() {
    return StreamBuilder<QuerySnapshot>(
        stream: participantService.getParticipantsStream(gameRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          return ValueListenableBuilder(
            valueListenable: percentage,
            builder: (context, value, widget) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: activeParticipants.length,
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
          );
        });
  }

  double calculateCircleFill() {
    List<String> answeredParticipantNames = scoreService.getAnsweredParticipantNames(questionScores);
    List<String> activeParticipantNames = activeParticipants.map((p) => p.name).toList();
    int activeAnswers = answeredParticipantNames.where((p) => activeParticipantNames.contains(p)).length;
    return activeAnswers / activeParticipants.length;
  }

  IconData renderIcon(String participantName) {
    List<String> answeredParticipantNames = scoreService.getAnsweredParticipantNames(questionScores);
    return answeredParticipantNames.contains(participantName) ? Icons.check : null;
  }
}
