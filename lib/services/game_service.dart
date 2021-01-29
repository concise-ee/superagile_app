import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/entities/score.dart';
import 'package:superagile_app/repositories/game_repository.dart';

final _random = Random();

int _generate4DigitPin() => _random.nextInt(9000) + 1000;

class GameService {
  final GameRepository _gameRepository = GameRepository();

  Future<int> generateAvailable4DigitPin() async {
    var pin = _generate4DigitPin();
    bool isPinAvailable = await isGameByPinAvailable(pin);
    while (!isPinAvailable) {
      pin = _generate4DigitPin();
      isPinAvailable = await isGameByPinAvailable(pin);
    }
    return pin;
  }

  Future<bool> isGameByPinAvailable(int pin) async {
    Game game = await _gameRepository.findActiveGameByPinNullable(pin);
    if (game == null) {
      return true;
    }
    return false;
  }

  Future<DocumentReference> addGame(Game game) {
    return _gameRepository.addGame(game);
  }

  Future<Game> findActiveGameByPin(int pin) {
    return _gameRepository.findActiveGameByPin(pin);
  }

  Future<DocumentReference> findActiveGameRefByPin(int pin) {
    return _gameRepository.findActiveGameRefByPin(pin);
  }

  Future<void> setScore(
      DocumentReference participantRef, DocumentReference gameRef, int questionNr, String scoreValue) async {
    var score = Score(questionNr, scoreValue != null ? int.parse(scoreValue) : null, participantRef.id);
    return _gameRepository.setScore(participantRef, score);
  }

  Stream<QuerySnapshot> getScoresStream(DocumentReference participantRef) {
    return _gameRepository.getScoresStream(participantRef);
  }

  Stream<DocumentSnapshot> getGameStream(DocumentReference gameRef) {
    return _gameRepository.getGameStream(gameRef);
  }

  Future<Game> findActiveGameByRef(DocumentReference gameRef) {
    return _gameRepository.findActiveGameByRef(gameRef);
  }

  Future<QuestionScores> findScoresForQuestion(DocumentReference gameReference, int questionNumber) {
    return _gameRepository.findScoresForQuestion(gameReference, questionNumber);
  }

  List<String> getAnsweredParticipantNames(QuestionScores questionScores) {
    return questionScores.answeredNull +
        questionScores.answered0 +
        questionScores.answered1 +
        questionScores.answered2 +
        questionScores.answered3;
  }

  void deleteOldScore(DocumentReference participantRef, int questionNr) {
    _gameRepository.deleteScore(participantRef, questionNr);
  }

  Future<void> changeGameState(DocumentReference gameRef, String gameState) async {
    return await _gameRepository.changeGameState(gameRef, gameState);
  }

  Future<String> getGameState(DocumentReference gameRef) async {
    Game game = await findActiveGameByRef(gameRef);
    return game.gameState;
  }

  Future<void> setAgreedScore(DocumentReference gameRef, int agreedScore, int questionNr) {
    return _gameRepository.setAgreedScores(gameRef, agreedScore, questionNr);
  }

  Future<Map<String, int>> getAgreedScores(DocumentReference gameRef) async {
    Game game = await findActiveGameByRef(gameRef);
    return game.agreedScores;
  }

  Future<int> getAgreedScoreForQuestion(DocumentReference gameRef, int questionNr) async {
    Map<String, int> agreedScores = await getAgreedScores(gameRef);
    return agreedScores[questionNr.toString()];
  }

  Future<int> getGamePinByRef(DocumentReference gameRef) async {
    Game game = await findActiveGameByRef(gameRef);
    return game.pin;
  }
}
