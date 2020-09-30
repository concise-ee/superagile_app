import 'dart:math';

import 'package:flutter/material.dart';
import 'package:superagile_app/constants/labels.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/repositories/game_repository.dart';

import 'game_start_waiting_page.dart';

final _random = new Random();

_generate6DigitPin() => _random.nextInt(900000) + 100000;

class HostStartPage extends StatefulWidget {
  @override
  _HostStartPageState createState() => _HostStartPageState();
}

class _HostStartPageState extends State<HostStartPage> {
  final GameRepository _gameRepository = GameRepository();
  final _nameController = TextEditingController();
  final game = Game(_generate6DigitPin(), []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(HASH_SUPERAGILE)),
        body: Container(
            padding: EdgeInsets.all(25),
            child: ListView(
              children: [
                Text(game.pin.toString(),
                    style: Theme.of(context).textTheme.headline6),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: ENTER_NAME),
                ),
                RaisedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      game.players.add(Player(
                          _nameController.text, DateTime.now().toString()));
                      _gameRepository.addGame(game).then((ref) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return GameStartWaitingPage(
                                game.pin, _nameController.text);
                          }),
                        );
                      });
                    },
                    child: Text(CONTINUE))
              ],
            )));
  }
}
