import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/entities/score.dart';
import 'package:superagile_app/repositories/game_repository.dart';
import 'package:superagile_app/repositories/player_repository.dart';

final _random = Random();

int _generate4DigitPin() => _random.nextInt(9000) + 1000;

class GameService {
  final GameRepository _gameRepository = GameRepository();
  final PlayerRepository _playerRepository = PlayerRepository();

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

  Future<DocumentReference> saveOrSetScore(
      DocumentReference playerRef, DocumentReference gameRef, int questionNr, String buttonValue) async {
    QuestionScores scores = await _gameRepository.findScoresForQuestion(gameRef, questionNr);
    Player player = await _playerRepository.findGamePlayerByRef(playerRef);
    var score = Score(questionNr, buttonValue != null ? int.parse(buttonValue) : null, playerRef.id);
    if (hasPlayerAnswered(scores, player)) {
      return _gameRepository.setScore(playerRef, score);
    }
    return _gameRepository.saveScore(playerRef, score);
  }

  bool hasPlayerAnswered(QuestionScores scores, Player player) {
    return scores.answered0.contains(player.name) ||
        scores.answered1.contains(player.name) ||
        scores.answered2.contains(player.name) ||
        scores.answered3.contains(player.name);
  }

  Stream<QuerySnapshot> getScoresStream(DocumentReference playerRef) {
    return _gameRepository.getScoresStream(playerRef);
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

  int getAnsweredPlayersCount(QuestionScores questionScores) {
    return questionScores.answeredNull.length +
        questionScores.answered0.length +
        questionScores.answered1.length +
        questionScores.answered2.length +
        questionScores.answered3.length;
  }

  void deleteOldScore(DocumentReference playerRef, int questionNr) {
    _gameRepository.deleteScore(playerRef, questionNr);
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

  Future<int> getAgreedTotalScore(DocumentReference gameRef) async {
    Game game = await findActiveGameByRef(gameRef);
    return game.agreedScores.values.reduce((sum, value) => sum + value);
  }
}
