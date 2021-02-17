import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/participant_service.dart';
import 'package:superagile_app/services/security_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/utils/game_state_utils.dart';
import 'package:superagile_app/utils/labels.dart';

import 'waiting_room_page.dart';

final _log = Logger((HostStartPage).toString());

class HostStartPage extends StatefulWidget {
  @override
  _HostStartPageState createState() => _HostStartPageState();
}

class _HostStartPageState extends State<HostStartPage> {
  final GameService _gameService = GameService();
  final ParticipantService _participantService = ParticipantService();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  bool reconnectToExistingGame = false;
  final _formKey = GlobalKey<FormState>();
  var hasPin = false;
  var hostExists = false;

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
                    Align(
                      alignment: Alignment.center,
                    ),
                    TextFormField(
                      maxLength: 25,
                      validator: (value) {
                        checkGame();
                        if (value.isEmpty) {
                          return WARNING_NAME;
                        }
                        if (reconnectToExistingGame) {
                          if (hostExists == true) {
                            return null;
                          } else {
                            return HOST_NAME_IS_DIFFERENT;
                          }
                        }
                        return null;
                      },
                      controller: _nameController,
                      decoration: InputDecoration(hintText: ENTER_NAME),
                    ),
                    if (reconnectToExistingGame) ...[
                      SizedBox(height: 25),
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
                            if (value.isEmpty) {
                              return WARNING_PIN;
                            }
                            if (hasPin) {
                              return null;
                            } else {
                              return PLEASE_ENTER_VALID_PIN;
                            }
                          },
                          controller: _pinController,
                          decoration: InputDecoration(hintText: ENTER_PIN))
                    ],
                    SwitchListTile(
                        title: Text(RECONNECT_TO_EXISTING_GAME, style: TextStyle(color: Colors.white, fontSize: 20)),
                        value: reconnectToExistingGame,
                        onChanged: (value) {
                          setState(() {
                            reconnectToExistingGame = !reconnectToExistingGame;
                          });
                        },
                        activeTrackColor: accentColor,
                        activeColor: accentColor,
                        controlAffinity: ListTileControlAffinity.leading),
                    Spacer(
                      flex: 1,
                    ),
                    if (!reconnectToExistingGame) ...[
                      ...renderNewGameDescriptionAndButtons(),
                    ],
                    if (reconnectToExistingGame) ...[
                      renderReconnectButton(),
                    ]
                  ],
                ))));
  }

  List<Widget> renderNewGameDescriptionAndButtons() {
    return [
      Flexible(
          fit: FlexFit.loose,
          flex: 3,
          child: Container(
              alignment: Alignment.center,
              child: Text(
                HOST_OR_JOIN,
                style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.5),
                textAlign: TextAlign.center,
              ))),
      Flexible(
          fit: FlexFit.loose,
          flex: 2,
          child: Container(
              alignment: Alignment.center,
              child: Text(
                DECISION_CANT_BE_CHANGED,
                style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1.5),
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
            if (_formKey.currentState.validate()) {
              FocusScope.of(context).unfocus();
              var loggedInUserUid = await signInAnonymously();
              var pin = await _gameService.generateAvailable4DigitPin();
              var gameRef = await _gameService.addGame(Game(pin, loggedInUserUid, true, null));
              var hostRef = await _participantService.addParticipant(gameRef,
                  Participant(_nameController.text, loggedInUserUid, DateTime.now().toString(), Role.HOST, true));
              await _gameService.changeGameState(gameRef, GameState.WAITING_ROOM);
              _log.info('${hostRef} HOST ${PLAYING_ALONG} and navigates to WaitingRoomPage');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return WaitingRoomPage(gameRef, hostRef);
                }),
              );
            }
            ;
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
            if (_formKey.currentState.validate()) {
              FocusScope.of(context).unfocus();
              var loggedInUserUid = await signInAnonymously();
              var pin = await _gameService.generateAvailable4DigitPin();
              var gameRef = await _gameService.addGame(Game(pin, loggedInUserUid, true, null));
              var hostRef = await _participantService.addParticipant(gameRef,
                  Participant(_nameController.text, loggedInUserUid, DateTime.now().toString(), Role.HOST, false));
              await _gameService.changeGameState(gameRef, GameState.WAITING_ROOM);
              _log.info('${hostRef} HOST ${JUST_A_HOST} and navigates to WaitingRoomPage');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return WaitingRoomPage(gameRef, hostRef);
                }),
              );
            }
            ;
          },
        ),
      )
    ];
  }

  Widget renderReconnectButton() {
    return Flexible(
      flex: 5,
      child: AgileButton(
        buttonTitle: RECONNECT,
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            FocusScope.of(context).unfocus();
            await signInAnonymously();
            var gameRef = await _gameService.findActiveGameRefByPin(int.parse(_pinController.text));
            if (gameRef == null) {
              _log.severe('HOST tried to rejoin ${_pinController.text} but no such game exists');
              throw ('Tried to reconnect as HOST but no such game exists.');
            }
            var hostRef = await _participantService.findParticipantRefByName(gameRef, _nameController.text);
            if (hostRef == null) {
              _log.severe('HOST tried to rejoin ${_pinController.text} but no such HOST exists in ${gameRef.id}');
              throw ('Tried to reconnect as HOST but no such HOST exists.');
            }
            Game game = await _gameService.findActiveGameByRef(gameRef);
            _log.info('${hostRef} tries to rejoin as HOST to game:${gameRef.id}');
            return joinCreatedGameAsExistingParticipant(game.gameState, hostRef, gameRef, context);
          }
        },
      ),
    );
  }

  checkGame() async {
    var gameRef = await _gameService.findActiveGameRefByPin(int.parse(_pinController.text));
    var hostRef = await _participantService.findParticipantRefByName(gameRef, _nameController.text);
    if (hostRef != null) {
      setState(() => hostExists = true);
    } else {
      setState(() => hostExists = false);
    }
  }
}
