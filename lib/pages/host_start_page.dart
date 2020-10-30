import 'dart:math';

import 'package:flutter/material.dart';
import 'package:superagile_app/Resources/AgileButton.dart';
import 'package:superagile_app/constants/labels.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/repositories/game_repository.dart';
import 'package:superagile_app/services/security_service.dart';

import 'game_start_waiting_page.dart';

final _random = Random();

int _generate6DigitPin() => _random.nextInt(900000) + 100000;

class HostStartPage extends StatefulWidget {
  @override
  _HostStartPageState createState() => _HostStartPageState();
}

class _HostStartPageState extends State<HostStartPage> {
  final GameRepository _gameRepository = GameRepository();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(HASH_SUPERAGILE)),
        body: Container(
            padding: EdgeInsets.all(25),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.center,
                ),
                Spacer(
                  flex: 2,
                ),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: ENTER_NAME),
                ),
                Spacer(
                  flex: 1,
                ),
                Flexible(
                    fit: FlexFit.loose,
                    flex: 3,
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          HOST_OR_JOIN,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 1.5),
                          textAlign: TextAlign.center,
                        ))),
                Flexible(
                    fit: FlexFit.loose,
                    flex: 2,
                    child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          DECISION_CANT_BE_CHANGED,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              letterSpacing: 1.5),
                          textAlign: TextAlign.center,
                        ))),
                Spacer(
                  flex: 1,
                ),
                Flexible(
                  flex: 5,
                  child: AgileButton(
                    buttonTitle: PLAYING_ALONG,
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      var loggedInUserUid = await signInAnonymously();
                      var game = await _gameRepository.addGame(Game(_generate6DigitPin()));
                      await _gameRepository.addGamePlayer(
                          game.reference,
                          Player(_nameController.text, loggedInUserUid,
                              DateTime.now().toString()));
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return GameStartWaitingPage(
                              game, _nameController.text);
                        }),
                      );
                    },
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Flexible(
                  flex: 5,
                  child: AgileButton(
                    buttonTitle: JUST_A_HOST,
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      var loggedInUserUid = await signInAnonymously();
                      var game = await _gameRepository.addGame(Game(_generate6DigitPin()));
                      await _gameRepository.addGamePlayer(
                          game.reference,
                          Player(_nameController.text, loggedInUserUid,
                              DateTime.now().toString()));
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return GameStartWaitingPage(
                              game, _nameController.text);
                        }),
                      );
                    },
                  ),
                ),
              ],
            )));
  }
}
