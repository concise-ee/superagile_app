import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/participant_service.dart';
import 'package:superagile_app/services/security_service.dart';
import 'package:superagile_app/ui/components/play_button.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/labels.dart';

final _log = Logger((PlayerStartPage).toString());

class PlayerStartPage extends StatefulWidget {
  @override
  _PlayerStartPageState createState() => _PlayerStartPageState();
}

class _PlayerStartPageState extends State<PlayerStartPage> {
  final _pinController = TextEditingController();
  final _nameController = TextEditingController();
  final GameService _gameService = GameService();
  final ParticipantService _participantService = ParticipantService();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(title: Text(HASH_SUPERAGILE)),
        body: Container(
            padding: EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: ENTER_PIN),
                ),
                SizedBox(height: 25),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: ENTER_NAME),
                ),
                SizedBox(height: 25),
                PlayButton(onPressed: () async {
                  FocusScope.of(context).unfocus();
                  var loggedInUserUid = await signInAnonymously();
                  var gameRef = await _gameService.findActiveGameRefByPin(int.parse(_pinController.text));
                  var playerRef = await _participantService.findParticipantRefByName(gameRef, _nameController.text);
                  if (playerRef != null) {
                    bool isPlayerActive = await _participantService.checkIfParticipantIsActive(playerRef);
                    _log.info('${playerRef} isPlayerActive:${isPlayerActive} tries to rejoin existing game as Player');
                    if (!isPlayerActive) {
                      Game game = await _gameService.findActiveGameByRef(gameRef);
                      _log.info('${playerRef} rejoins existing game:${gameRef.id} as Player');
                      return joinCreatedGameAsExistingParticipant(game.gameState, playerRef, gameRef, context);
                    }
                    _log.severe('${playerRef} tried to join with active participant name');
                    throw ('Cannot use active participant name');
                  }
                  _log.info('${playerRef} joins as new Player');
                  return joinAsNewPlayer(gameRef, loggedInUserUid);
                }),
              ],
            )));
  }

  Future<MaterialPageRoute<dynamic>> joinAsNewPlayer(DocumentReference gameRef, String loggedInUserUid) async {
    DocumentReference playerRef = await _participantService.addParticipant(
        gameRef, Participant(_nameController.text, loggedInUserUid, DateTime.now().toString(), Role.PLAYER, true));
    Game game = await _gameService.findActiveGameByRef(gameRef);
    return joinCreatedGameAsExistingParticipant(game.gameState, playerRef, gameRef, context);
  }
}
