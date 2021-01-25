import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/player_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/game_pin.dart';
import 'package:superagile_app/ui/views/start_page.dart';
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
  Map<String, int> agreedScores;
  bool isLoading = true;
  int gamePin;

  _FinalPage(this.playerRef, this.gameRef);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    var totalScore = await gameService.getAgreedScores(gameRef);
    var pin = await gameService.getGamePinByRef(gameRef);
    setState(() {
      agreedScores = totalScore;
      isLoading = false;
      gamePin = pin;
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
    return new WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: new Scaffold(
        appBar: AppBar(title: Text(HASH_SUPERAGILE), automaticallyImplyLeading: false),
        body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      children: [
        Row(children: [GamePin(gamePin: this.gamePin)]),
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
            Text('Question: ${score.key}, score: ${score.value}',
                style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 1.5), textAlign: TextAlign.center)
          ]),
        ),
    ]);
  }
}
