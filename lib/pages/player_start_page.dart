import 'package:flutter/material.dart';
import 'package:superagile_app/constants/Labels.dart';
import 'package:superagile_app/entities/Player.dart';
import 'package:superagile_app/pages/game_start_waiting_page.dart';
import 'package:superagile_app/repositories/game_repository.dart';

class PlayerStartPage extends StatefulWidget {
  @override
  _PlayerStartPageState createState() => _PlayerStartPageState();
}

class _PlayerStartPageState extends State<PlayerStartPage> {
  final _pinController = TextEditingController();
  final _nameController = TextEditingController();
  final GameRepository _gameRepository = GameRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(HASH_SUPERAGILE)),
        body: Container(
            padding: EdgeInsets.all(25),
            child: ListView(
              children: [
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: ENTER_PIN),
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: ENTER_NAME),
                ),
                RaisedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _gameRepository
                          .findGameByPin(int.parse(_pinController.text))
                          .then((game) {
                        if (game != null) {
                          game.players.add(Player(
                              _nameController.text, DateTime.now().toString()));
                          _gameRepository.updateGame(game);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return GameStartWaitingPage(
                                  int.parse(_pinController.text),
                                  _nameController.text);
                            }),
                          );
                        }
                      });
                    },
                    child: Text(PLAY)),
              ],
            )));
  }
}
