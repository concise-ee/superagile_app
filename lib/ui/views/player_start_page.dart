import 'package:flutter/material.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/security_service.dart';
import 'package:superagile_app/ui/views/waiting_room_page.dart';
import 'package:superagile_app/utils/labels.dart';

class PlayerStartPage extends StatefulWidget {
  @override
  _PlayerStartPageState createState() => _PlayerStartPageState();
}

class _PlayerStartPageState extends State<PlayerStartPage> {
  static const PLAYER = 'PLAYER';
  final _pinController = TextEditingController();
  final _nameController = TextEditingController();
  final GameService _gameService = GameService();

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
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      var game = await _gameService.findActiveGameByPin(int.parse(_pinController.text));
                      if (game != null) {
                        var loggedInUserUid = await signInAnonymously();
                        var player =
                            Player(_nameController.text, loggedInUserUid, DateTime.now().toString(), PLAYER, true);
                        _gameService.addGamePlayer(game.reference, player);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return WaitingRoomPage(game, player);
                          }),
                        );
                      }
                    },
                    child: Text(PLAY)),
              ],
            )));
  }
}