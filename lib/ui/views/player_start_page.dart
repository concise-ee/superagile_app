import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/player_service.dart';
import 'package:superagile_app/services/security_service.dart';
import 'package:superagile_app/ui/views/waiting_room_page.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/labels.dart';

class PlayerStartPage extends StatefulWidget {
  @override
  _PlayerStartPageState createState() => _PlayerStartPageState();
}

class _PlayerStartPageState extends State<PlayerStartPage> {
  final _pinController = TextEditingController();
  final _nameController = TextEditingController();
  final GameService _gameService = GameService();
  final PlayerService _playerService = PlayerService();

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
                      var loggedInUserUid = await signInAnonymously();
                      var gameRef = await _gameService.findActiveGameRefByPin(int.parse(_pinController.text));
                      var playerRef = await _playerService.findPlayerRefByName(gameRef, _nameController.text);
                      if (playerRef != null) {
                        Game game = await _gameService.findActiveGameByRef(gameRef);
                        return joinCreatedGameAsExistingUser(game.gameState, playerRef, gameRef, context);
                      }
                      return joinWaitingRoomAsNewPlayer(gameRef, loggedInUserUid);
                    },
                    child: Text(PLAY)),
              ],
            )));
  }

  Future<WaitingRoomPage> joinWaitingRoomAsNewPlayer(DocumentReference gameRef, String loggedInUserUid) async {
    DocumentReference playerRef = await _playerService.addGamePlayer(
        gameRef, Player(_nameController.text, loggedInUserUid, DateTime.now().toString(), Role.PLAYER, true));
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return WaitingRoomPage(gameRef, playerRef);
      }),
    );
  }
}
