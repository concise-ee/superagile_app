import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/question.dart';
import 'package:superagile_app/entities/score.dart';
import 'package:superagile_app/repositories/question_repository.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/utils/labels.dart';

class GameQuestionPage extends StatefulWidget {
  final int _questionNr;
  final Player _player;
  final Game _game;

  GameQuestionPage(this._questionNr, this._player, this._game);

  @override
  _GameQuestionPage createState() => _GameQuestionPage();
}

class _GameQuestionPage extends State<GameQuestionPage> {
  final QuestionRepository _questionRepository = QuestionRepository();
  final GameService _gameService = GameService();
  var questionNr;
  var player;
  var game;
  Question question;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    questionNr = widget._questionNr;
    player = widget._player;
    game = widget._game;
    loadQuestionContentByNumber();
    return Scaffold(
      appBar: AppBar(title: Text(HASH_SUPERAGILE)),
      body: _buildBody(context),
    );
  }

  void loadQuestionContentByNumber() async {
    final Question questionByNumber = await _questionRepository.findQuestionByNumber(questionNr);
    setState(() {
      question = questionByNumber;
    });
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
                  FocusScope.of(context).unfocus();
                  var players = await _gameService.findGamePlayers(game.reference);
                  var currentPlayer = players.where((player) => player.name == player.name).single;
                  var gae = await _gameService.findActiveGameByPin(game.pin);
                  var score = Score(questionNr, int.parse(ZERO));
                  _gameService.addScore(gae.reference, currentPlayer, score);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return GameQuestionPage(questionNr + 1, currentPlayer, game);
                    }),
                  );
                },
              ),
            ),
            Expanded(
              child: AgileButton(
                buttonTitle: ONE,
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  var players = await _gameService.findGamePlayers(game.reference);
                  var currentPlayer = players.where((player) => player.name == player.name).single;
                  var gae = await _gameService.findActiveGameByPin(game.pin);
                  var score = Score(questionNr, int.parse(ONE));
                  _gameService.addScore(gae.reference, currentPlayer, score);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return GameQuestionPage(questionNr + 1, currentPlayer, game);
                    }),
                  );
                },
              ),
            ),
            Expanded(
              child: AgileButton(
                buttonTitle: TWO,
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  var players = await _gameService.findGamePlayers(game.reference);
                  var currentPlayer = players.where((player) => player.name == player.name).single;
                  var gae = await _gameService.findActiveGameByPin(game.pin);
                  var score = Score(questionNr, int.parse(TWO));
                  _gameService.addScore(gae.reference, currentPlayer, score);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return GameQuestionPage(questionNr + 1, currentPlayer, game);
                    }),
                  );
                },
              ),
            ),
            Expanded(
              child: AgileButton(
                buttonTitle: THREE,
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  var players = await _gameService.findGamePlayers(game.reference);
                  var currentPlayer = players.where((player) => player.name == player.name).single;
                  var gae = await _gameService.findActiveGameByPin(game.pin);
                  var score = Score(questionNr, int.parse(THREE));
                  _gameService.addScore(gae.reference, currentPlayer, score);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return GameQuestionPage(questionNr + 1, currentPlayer, game);
                    }),
                  );
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
