import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/entities/role.dart';
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

  List<Player> findActivePlayers(List<QueryDocumentSnapshot> snaps) {
    return snaps
        .map((playerSnap) => Player.fromSnapshot(playerSnap))
        .where((player) => player.isPlayingAlong == true)
        .where((player) => DateTime.parse(player.lastActive).isAfter(DateTime.now().subtract(Duration(seconds: 11))))
        .toList();
  }

  void sendLastActive(DocumentReference playerRef) async {
    Player player = await _gameRepository.findGamePlayerByRef(playerRef);
    player.lastActive = DateTime.now().toString();
    _gameRepository.updateGamePlayer(player);
  }

  Future<DocumentReference> addGame(Game game) {
    return _gameRepository.addGame(game);
  }

  Future<DocumentReference> addGamePlayer(DocumentReference reference, Player player) {
    return _gameRepository.addGamePlayer(reference, player);
  }

  Future<Game> findActiveGameByPin(int pin) {
    return _gameRepository.findActiveGameByPin(pin);
  }

  Future<DocumentReference> findActiveGameRefByPin(int pin) {
    return _gameRepository.findActiveGameRefByPin(pin);
  }

  Future<List<Player>> findGamePlayers(DocumentReference gameRef) {
    return _gameRepository.findGamePlayers(gameRef);
  }

  Future<bool> isPlayerHosting(DocumentReference playerRef) async {
    Player player = await _gameRepository.findGamePlayerByRef(playerRef);
    return player.role == Role.HOST;
  }

  Future<DocumentReference> saveOrSetScore(DocumentReference playerRef, DocumentReference gameRef, int questionNr, int buttonValue) async {
    QuestionScores scores = await _gameRepository.findScoresForQuestion(gameRef, questionNr);
    Player player = await _gameRepository.findGamePlayerByRef(playerRef);
    var score = Score(questionNr, buttonValue, playerRef.id);
    if (hasPlayerAnswered(scores, player)) {
      return _gameRepository.setScore(playerRef, score);
    }
    return _gameRepository.saveScore(playerRef, score);
  }

  bool hasPlayerAnswered(QuestionScores scores, Player player) {
    return scores.answered0.contains(player.name)
      || scores.answered1.contains(player.name)
      || scores.answered2.contains(player.name)
      || scores.answered3.contains(player.name);
  }

  Stream<QuerySnapshot> getGamePlayersStream(DocumentReference gameRef) {
    return _gameRepository.getGamePlayersStream(gameRef);
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
    return questionScores.answered0.length +
        questionScores.answered1.length +
        questionScores.answered2.length +
        questionScores.answered3.length;
  }

  void deleteOldScore(DocumentReference playerRef, int questionNr) {
    _gameRepository.deleteScore(playerRef, questionNr);
  }

  void changeGameState(DocumentReference gameRef, String gameState) {
    _gameRepository.changeGameState(gameRef, gameState);
  }
}
