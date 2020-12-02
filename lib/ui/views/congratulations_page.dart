import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/ui/components/play_button.dart';
import 'package:superagile_app/ui/views/game_question_page.dart';
import 'package:superagile_app/utils/labels.dart';

class CongratulationPage extends StatefulWidget {
  final int _questionNr;
  final DocumentReference _playerRef;
  final DocumentReference _gameRef;

  CongratulationPage(this._questionNr, this._playerRef, this._gameRef);

  @override
  _CongratulationPage createState() => _CongratulationPage(this._questionNr, this._playerRef, this._gameRef);
}

class _CongratulationPage extends State<CongratulationPage> {
  final int questionNr;
  final DocumentReference playerRef;
  final DocumentReference gameRef;

  _CongratulationPage(this.questionNr, this.playerRef, this.gameRef);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(HASH_SUPERAGILE)),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Container(
                        child: Padding(
                  padding: EdgeInsets.all(50.0),
                  child: Text(TEAMS_RESULTS + questionNr.toString() + ':',
                      style: TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 1.5),
                      textAlign: TextAlign.center),
                ))),
              ],
            ),
          ],
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        CONGRATS,
                        style: TextStyle(
                            color: Colors.yellowAccent, fontSize: 28, letterSpacing: 3, fontWeight: FontWeight.bold),
                      )),
                ))
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      GREAT_MINDS,
                      style: TextStyle(color: Colors.yellowAccent, fontSize: 22, letterSpacing: 1.5),
                    )),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(GO_TO_NEXT_QUESTION,
                        style: TextStyle(color: Colors.yellowAccent, fontSize: 14, letterSpacing: 1.5),
                        textAlign: TextAlign.center)),
              ),
            )
          ],
        ),
        Row(
          children: [
            Expanded(
                child: Align(
              alignment: Alignment.bottomLeft,
              child: PlayButton(
                onPressed: () {
                  return GameQuestionPage(questionNr + 1, playerRef, gameRef);
                },
              ),
            ))
          ],
        )
      ],
    );
  }
}
