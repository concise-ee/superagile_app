import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
  final _formKey = GlobalKey<FormState>();
  var gameExists = true;
  var isParticipantActive = false;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: AppBar(title: Text(HASH_SUPERAGILE)),
            body: Container(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      onChanged: (text) async {
                        var gameRef = await _gameService.findActiveGameRefByPin(int.parse(text));
                        if (gameRef == null) {
                          setState(() => hasPin = false);
                        } else {
                          setState(() => hasPin = true);
                        }
                      },
                      validator: (value) {
                        if (!gameExists || value.isEmpty) {
                          return PLEASE_ENTER_VALID_PIN;
                        }
                        return null;
                      },
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(hintText: ENTER_PIN),
                    ),
                    SizedBox(height: 25),
                    TextFormField(
                      maxLength: 25,
                      validator: (value) => validateNameField(value),
                      controller: _nameController,
                      decoration: InputDecoration(hintText: ENTER_NAME),
                    ),
                    SizedBox(height: 25),
                    PlayButton(onPressed: () async {
                      FocusScope.of(context).unfocus();
                      var loggedInUserUid = await signInAnonymously();
                      checkIfPinIsEmpty();
                      var gameRef = await _gameService.findActiveGameRefByPin(int.parse(_pinController.text));
                      if (gameRef == null) {
                        _log.severe('PLAYER tried to rejoin ${_pinController.text} but no such game exists');
                        setState(() => gameExists = false);
                        setState(() => isParticipantActive = false);
                        _formKey.currentState.validate();
                        throw ('Tried to reconnect as PLAYER but no such game exists.');
                      }
                      setState(() => gameExists = true);
                      _formKey.currentState.validate();
                      checkIfNameIsEmpty();
                      var playerRef = await _participantService.findParticipantRefByName(gameRef, _nameController.text);
                      if (playerRef != null) {
                        bool isPlayerActive = await _participantService.checkIfParticipantIsActive(playerRef);
                        _log.info(
                            '${playerRef} isPlayerActive:${isPlayerActive} tries to rejoin existing game as Player');
                        if (!isPlayerActive) {
                          Game game = await _gameService.findActiveGameByRef(gameRef);
                          _log.info('${playerRef} rejoins existing game:${gameRef.id} as Player');
                          return joinCreatedGameAsExistingParticipant(game.gameState, playerRef, gameRef, context);
                        }
                        _log.severe('${playerRef} tried to join with active participant name');
                        setState(() => isParticipantActive = true);
                        if (gameRef != null) {
                          setState(() => gameExists = true);
                        }
                        _formKey.currentState.validate();
                        throw ('Cannot use active participant name');
                      }
                      setState(() => isParticipantActive = false);
                      _log.info('New player joins');
                      if (_formKey.currentState.validate()) {
                        return joinAsNewPlayer(gameRef, loggedInUserUid);
                      }
                    }),
                  ],
                ))));
  }

  String validateNameField(String value) {
    if (value.isEmpty) {
      return WARNING_NAME;
    }
    if (isParticipantActive) {
      return PLAYER_IS_ALREADY_IN_GAME;
    }
    return null;
  }

  void checkIfNameIsEmpty() {
    if (_nameController.text.isEmpty) {
      setState(() => isParticipantActive = false);
      _formKey.currentState.validate();
      throw ('Name cannot be empty.');
    }
  }

  void checkIfPinIsEmpty() {
    if (_pinController.text.isEmpty) {
      setState(() => gameExists = false);
      _formKey.currentState.validate();
      throw ('Pin cannot be empty.');
    }
  }

  checkGame() async {
    var gameRef = await _gameService.findActiveGameRefByPin(int.parse(_pinController.text));
    var playerRef = await _participantService.findParticipantRefByName(gameRef, _nameController.text);
    if (playerRef != null) {
      bool isPlayerActive = await _participantService.checkIfParticipantIsActive(playerRef);
      if (isPlayerActive) {
        setState(() => isParticipantActive = true);
      } else {
        setState(() => isParticipantActive = false);
      }
    } else {
      setState(() => isParticipantActive = false);
    }
  }

  Future<MaterialPageRoute<dynamic>> joinAsNewPlayer(DocumentReference gameRef, String loggedInUserUid) async {
    DocumentReference playerRef = await _participantService.addParticipant(
        gameRef, Participant(_nameController.text, loggedInUserUid, DateTime.now().toString(), Role.PLAYER, true));
    Game game = await _gameService.findActiveGameByRef(gameRef);
    return joinCreatedGameAsExistingParticipant(game.gameState, playerRef, gameRef, context);
  }
}
