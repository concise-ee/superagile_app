import 'dart:math';

import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
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

  Future<Game> addGame(Game game) {
    return _gameRepository.addGame(game);
  }

  void addGamePlayer(reference, Player player) {
    _gameRepository.addGamePlayer(reference, player);
  }

  Future<Game> findActiveGameByPin(int pin) {
    return _gameRepository.findActiveGameByPin(pin);
  }

  Future<List<Player>> findGamePlayers(reference) {
    return _gameRepository.findGamePlayers(reference);
  }

  void addScore(reference, currentPlayer, Score score) {
    _gameRepository.addScore(reference, currentPlayer, score);
  }
}
