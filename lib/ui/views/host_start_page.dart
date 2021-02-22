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
  final _formKey = GlobalKey<FormState>();

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
                      key: Key('nameField'),
                      maxLength: 25,
                      validator: (value) {
                        if (value.isEmpty) {
                          return WARNING_NAME_EMPTY;
                        }
                        if (value.length > 25) {
                          return WARNING_NAME_TOO_LONG;
                        }
                        return null;
                      },
                      controller: _nameController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(hintText: YOUR_NAME),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    ...renderNewGameDescriptionAndButtons(),
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
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ))),
      Flexible(
          fit: FlexFit.loose,
          flex: 2,
          child: Container(
              alignment: Alignment.center,
              child: Text(
                DECISION_CANT_BE_CHANGED,
                style: TextStyle(fontSize: 14),
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
            await createGameAndNavigateToWaitingRoom(true);
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
            await createGameAndNavigateToWaitingRoom(false);
          },
        ),
      )
    ];
  }

  Future<MaterialPageRoute<dynamic>> createGameAndNavigateToWaitingRoom(bool isPlayingAlong) async {
    if (!_formKey.currentState.validate()) {
      return null;
    }

    var loggedInUserUid = await signInAnonymously();
    var pin = await _gameService.generateAvailable4DigitPin();
    var gameRef = await _gameService.addGame(Game(pin, loggedInUserUid, true, null));
    var hostRef = await _participantService.addParticipant(gameRef,
        Participant(_nameController.text, loggedInUserUid, DateTime.now().toString(), Role.HOST, isPlayingAlong));
    await _gameService.changeGameState(gameRef, GameState.WAITING_ROOM);
    _log.info('${hostRef} HOST isPlayingAlong:${isPlayingAlong} and navigates to WaitingRoomPage');
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return WaitingRoomPage(gameRef, hostRef);
      }),
    );
  }
}
