import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/player_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/play_button.dart';
import 'package:superagile_app/ui/views/game_question_page.dart';
import 'package:superagile_app/ui/views/start_page.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/globals.dart';
import 'package:superagile_app/utils/labels.dart';

class FinalPage extends StatefulWidget {
  final DocumentReference _playerRef;
  final DocumentReference _gameRef;

  FinalPage(this._playerRef, this._gameRef);

  @override
  _FinalPage createState() => _FinalPage(this._playerRef, this._gameRef);
}

class _FinalPage extends State<FinalPage> {
  final DocumentReference playerRef;
  final DocumentReference gameRef;
  final GameService gameService = GameService();
  final PlayerService playerService = PlayerService();
  StreamSubscription<DocumentSnapshot> gameStream;
  Map<String, int> agreedScores;
  bool isLoading = true;

  _FinalPage(this.playerRef, this.gameRef);

  @override
  void initState() {
    super.initState();
    loadDataAndSetupListener();
  }

  @override
  void dispose() {
    gameStream.cancel();
    super.dispose();
  }

  void loadDataAndSetupListener() async {
    var totalScore = await gameService.getAgreedScores(gameRef);
    setState(() {
      agreedScores = totalScore;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(HASH_SUPERAGILE)),
      body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Container(
          child: Text('${OVERALL_SCORE}: ${agreedScores.values.reduce((sum, value) => sum + value)}',
              style: TextStyle(color: Colors.yellow, fontSize: 24, letterSpacing: 1.5),
              textAlign: TextAlign.center),
        ),
        buildSeparateScore(),
        Container(
          child: AgileButton(
            onPressed: () {
              activityTimer.cancel();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return StartPage();
                }),
              );
            }, buttonTitle: 'Back to the beginning',
          ),
        ),
      ],
    );
    return ListView(
      children: [
        Column(
          children: [
            Expanded(child:
            Row(
              children: [
                Container(
                        child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('${OVERALL_SCORE}: ${agreedScores.values.reduce((sum, value) => sum + value)}',
                      style: TextStyle(color: Colors.yellow, fontSize: 24, letterSpacing: 1.5),
                      textAlign: TextAlign.center),
                )),
              ],
            )),

          ],
        ),
          Row(
            children: [
              Align(
                child: AgileButton(
                  onPressed: () {
                    activityTimer.cancel();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return StartPage();
                      }),
                    );
                  }, buttonTitle: 'Back to the beginning',
                ),
              )
            ],
          )
      ],
    );
  }

  Widget buildSeparateScore() {
    return Column(children: [
    for( var i = 0 ; i < 30; i++ )
      Container(
        child:       Row(
            children: <Widget>[
              Text('Question: ${i} score: value 123',
                  style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 1.5), textAlign: TextAlign.center)
            ]),
      ),
    ]);
  }
}
