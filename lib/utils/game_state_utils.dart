import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:superagile_app/ui/views/congratulations_page.dart';
import 'package:superagile_app/ui/views/final_page.dart';
import 'package:superagile_app/ui/views/game_question_page.dart';
import 'package:superagile_app/ui/views/question_results_page.dart';
import 'package:superagile_app/ui/views/waiting_room_page.dart';

class GameState {
  static const String WAITING_ROOM = 'waitingRoom';
  static const String QUESTION = 'question';
  static const String QUESTION_RESULTS = 'results';
  static const String CONGRATULATIONS = 'congratulations';
  static const String FINAL = 'final';
}

const String STATE_NUMBER_DELIMITER = '_';
final _log = Logger('GameStateUtils');
int parseSequenceNumberFromGameState(String gameState) => int.parse(gameState.split(STATE_NUMBER_DELIMITER).last);

Future<MaterialPageRoute<dynamic>> joinCreatedGameAsExistingParticipant(
    String gameState, DocumentReference participantRef, DocumentReference gameRef, BuildContext context) {
  return Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) {
      if (gameState == GameState.WAITING_ROOM) {
        return WaitingRoomPage(gameRef, participantRef);
      }
      if (gameState.contains(GameState.QUESTION)) {
        return GameQuestionPage(parseSequenceNumberFromGameState(gameState), participantRef, gameRef);
      }
      if (gameState.contains(GameState.QUESTION_RESULTS)) {
        return QuestionResultsPage(
            questionNr: parseSequenceNumberFromGameState(gameState), gameRef: gameRef, participantRef: participantRef);
      }
      if (gameState.contains(GameState.CONGRATULATIONS)) {
        return CongratulationsPage(parseSequenceNumberFromGameState(gameState), participantRef, gameRef);
      }
      if (gameState == GameState.FINAL) {
        return FinalPage(participantRef, gameRef);
      }
      _log.severe('${gameRef} state ${gameState} and route page does not match.');
      throw ('Game state and route page does not match.');
    }),
  );
}
