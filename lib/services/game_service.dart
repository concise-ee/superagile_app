import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/score.dart';
import 'package:superagile_app/repositories/game_repository.dart';
import 'package:superagile_app/utils/labels.dart';

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

  Future<List<Player>> findGamePlayers(DocumentReference reference) {
    return _gameRepository.findGamePlayers(reference);
  }

  Future<bool> isPlayerHosting(DocumentReference playerRef) async {
    Player player = await _gameRepository.findGamePlayerByRef(playerRef);
    return player.role == ROLE_HOST;
  }

  void addScore(DocumentReference playerRef, Score score) {
    _gameRepository.addScore(playerRef, score);
  }

  Stream<QuerySnapshot> getGamePlayersStream(DocumentReference gameRef) {
    return _gameRepository.getGamePlayersStream(gameRef);
  }

  Future<Game> findActiveGameByRef(DocumentReference gameRef) {
    return _gameRepository.findActiveGameByRef(gameRef);
  }
}
