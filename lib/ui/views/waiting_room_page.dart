import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/role.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/participant_service.dart';
import 'package:superagile_app/services/timer_service.dart';
import 'package:superagile_app/ui/components/agile_with_back_icon_button.dart';
import 'package:superagile_app/ui/components/back_alert_dialog.dart';
import 'package:superagile_app/ui/components/play_button.dart';
import 'package:superagile_app/ui/components/question_mark%20_button.dart';
import 'package:superagile_app/utils/game_state_router.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/utils/mixpanel_utils.dart';

import 'game_question_page.dart';

final _log = Logger((WaitingRoomPage).toString());
const String QUESTION_1 = '${GameState.QUESTION}_1';

class WaitingRoomPage extends StatefulWidget {
  final DocumentReference _gameRef;
  final DocumentReference _participantRef;

  WaitingRoomPage(this._gameRef, this._participantRef);

  @override
  _WaitingRoomPageState createState() => _WaitingRoomPageState(this._gameRef, this._participantRef);
}

class _WaitingRoomPageState extends State<WaitingRoomPage> {
  final GameService gameService = GameService();
  final ParticipantService participantService = ParticipantService();
  final TimerService timerService = TimerService();
  final DocumentReference gameRef;
  final DocumentReference participantRef;
  Timer timer;
  String gamePin = '';
  StreamSubscription<DocumentSnapshot> gameStream;
  Role role;
  bool isLoading = true;

  _WaitingRoomPageState(this.gameRef, this.participantRef);

  @override
  void setState(state) {
    if (mounted) {
      super.setState(state);
    }
  }

  @override
  void initState() {
    super.initState();
    timerService.startActivityTimer(participantRef);
    loadDataAndSetupListener();
  }

  void loadDataAndSetupListener() async {
    await loadData();
    listenForUpdateToGoToQuestionPage();
  }

  Future<void> loadData() async {
    Game game = await gameService.findActiveGameByRef(gameRef);
    Participant participant = await participantService.findGameParticipantByRef(participantRef);
    setState(() {
      gamePin = game.pin.toString();
      role = participant.role;
      isLoading = false;
    });
  }

  void listenForUpdateToGoToQuestionPage() {
    gameStream = gameService.getGameStream(gameRef).listen((event) async {
      if (Game.fromSnapshot(event).gameState == QUESTION_1) {
        _log.info('${participantRef} navigates to GameQuestionPage, gameState: ${QUESTION_1}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            return GameQuestionPage(1, participantRef, gameRef);
          }),
        );
      }
    });
  }

  @override
  void dispose() {
    gameStream.cancel();
    super.dispose();
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => BackDialogAlert(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(),
      child: Scaffold(
          appBar: AppBar(
            title: AgileWithBackIconButton(_onBackPressed),
            automaticallyImplyLeading: false,
            actions: [QuestionMarkButton()],
          ),
          body: isLoading ? Center(child: CircularProgressIndicator()) : buildBody()),
    );
  }

  Widget buildBody() {
    return SingleChildScrollView(
        child: Column(children: [
      Align(
        alignment: Alignment.center,
      ),
      Container(
        child: Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text(WAITING_ROOM, textAlign: TextAlign.center, style: TextStyle(fontSize: fontLarge))),
      ),
      if (role == Role.HOST) buildHostView(),
      if (role == Role.PLAYER) buildPlayerView(),
    ]));
  }

  Widget buildParticipantCount() {
    return StreamBuilder<QuerySnapshot>(
        stream: participantService.getParticipantsStream(gameRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          var participants = participantService.findActiveParticipants(snapshot.data.docs);
          var text = '';
          if (participants.length > 1) {
            text = 'There are ' + participants.length.toString() + ' people in this workshop.';
          } else if (participants.length == 1) {
            text = 'There is 1 person in this workshop.';
          } else {
            text = 'There are no people in this workshop yet.';
          }
          return Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(text,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: role == Role.PLAYER ? fontLarge : fontMedium, fontWeight: FontWeight.normal)),
          );
        });
  }

  Widget buildActiveParticipantsWidget() {
    return StreamBuilder<QuerySnapshot>(
        stream: participantService.getParticipantsStream(gameRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          var participants = participantService.findActiveParticipants(snapshot.data.docs);
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: participants.length,
            itemBuilder: (context, index) {
              return Container(
                child: Padding(
                  padding: EdgeInsets.only(left: 55, right: 30, top: 20),
                  child: Text(
                    participants[index].name,
                    style: TextStyle(color: white, fontSize: 20),
                  ),
                ),
              );
            },
          );
        });
  }

  Widget buildStartGameButton() {
    return PlayButton(onPressed: () async {
      mixpanel.track('waiting_room_page: PLAY BUTTON');
      await gameService.changeGameState(gameRef, QUESTION_1);
      _log.info('${participantRef} HOST changed gameState to: ${QUESTION_1}');
    });
  }

  Widget buildText(String text) {
    return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: fontSmall));
  }

  Widget buildPlayerView() {
    return Column(children: [
      Padding(
        padding: EdgeInsets.only(left: 60, right: 60, top: 20, bottom: 60),
        child: buildText(CLICK_THE_QUESTION_MARK),
      ),
      Padding(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: buildParticipantCount(),
      ),
      Image.asset('lib/assets/superagile_wheel.png'),
    ]);
  }

  Widget buildHostView() {
    return Column(children: [
      buildBorderedText(gamePin),
      buildParticipantCount(),
      buildActiveParticipantsWidget(),
      buildStartGameButton()
    ]);
  }

  Widget buildBorderedText(String text) {
    return Container(
      margin: const EdgeInsets.all(30.0),
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 50, right: 50),
      decoration: BoxDecoration(border: Border.all(width: 3.0, color: secondaryColor)),
      child: Column(
        children: [
          Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: fontExtraLarge, color: accentColor)),
          buildText(CODE_SHARE_CALL)
        ],
      ),
    );
  }
}
