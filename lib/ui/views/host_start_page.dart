import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/participant_service.dart';
import 'package:superagile_app/services/security_service.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/agile_with_back_icon_button.dart';
import 'package:superagile_app/ui/components/question_mark%20_button.dart';
import 'package:superagile_app/ui/components/rounded_text_form_field.dart';
import 'package:superagile_app/utils/game_state_router.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/utils/mixpanel_utils.dart';

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
  var _firstPress = true;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Scaffold(
            appBar: AppBar(
                title: AgileWithBackIconButton(() => Navigator.pop(context)),
                actions: [QuestionMarkButton()],
                automaticallyImplyLeading: false),
            body: Center(
              child: SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RoundedTextFormField(
                          key: Key('nameField'),
                          maxLength: 15,
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value.isEmpty) {
                              return WARNING_NAME_EMPTY;
                            }
                            return null;
                          },
                          controller: _nameController,
                          hintText: YOUR_NAME,
                        ),
                        SizedBox(height: 50),
                        ...renderNewGameDescriptionAndButtons(),
                      ],
                    )),
              ),
            )));
  }

  List<Widget> renderNewGameDescriptionAndButtons() {
    return [
      Container(
          alignment: Alignment.center,
          child: Text(
            HOST_OR_JOIN,
            style: TextStyle(
              fontSize: fontSmall,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          )),
      SizedBox(height: 25),
      Container(
          alignment: Alignment.center,
          child: Text(
            DECISION_CANT_BE_CHANGED,
            style: TextStyle(fontSize: fontSmall, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          )),
      SizedBox(height: 50),
      AgileButton(
        buttonTitle: VOTE_WITH_TEAM,
        onPressed: () async {
          mixpanel.track('host_start_page: VOTE WITH TEAM');
          FocusScope.of(context).unfocus();
          await createGameAndNavigateToWaitingRoom(true);
        },
      ),
      SizedBox(height: 50),
      AgileButton(
        buttonTitle: LEAD_THE_WORKSHOP,
        onPressed: () async {
          mixpanel.track('host_start_page: LEAD THE WORKSHOP');
          FocusScope.of(context).unfocus();
          await createGameAndNavigateToWaitingRoom(false);
        },
      ),
    ];
  }

  Future<MaterialPageRoute<dynamic>> createGameAndNavigateToWaitingRoom(
      bool isPlayingAlong) async {
    if (!_formKey.currentState.validate()) {
      return null;
    }

    if (_firstPress) {
      _firstPress = false;
      var loggedInUserUid = await signInAnonymously();
      var pin = await _gameService.generateAvailable4DigitPin();
      var gameRef =
          await _gameService.addGame(Game(pin, loggedInUserUid, true, null));
      var hostRef = await _participantService.addParticipant(
          gameRef,
          Participant(_nameController.text, loggedInUserUid,
              DateTime.now().toString(), Role.HOST, isPlayingAlong));
      await _gameService.changeGameState(gameRef, GameState.WAITING_ROOM);
      _log.info(
          '${hostRef} HOST isPlayingAlong:${isPlayingAlong} and navigates to WaitingRoomPage');
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return WaitingRoomPage(gameRef, hostRef);
        }),
      );
    } else {
      return null;
    }
  }
}
