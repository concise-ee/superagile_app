import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/repositories/game_repository.dart';
import 'package:superagile_app/utils/pin_utils.dart';

class GameService {
  final GameRepository _gameRepository = GameRepository();

  Future<int> generateAvailable4DigitPin() async {
    var pin = generate4DigitPin();
    bool isPinAvailable = await isGameByPinAvailable(pin);
    while (!isPinAvailable) {
      pin = generate4DigitPin();
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
    return _gameRepository.findActiveGameRefByPinNullable(pin);
  }

  Stream<DocumentSnapshot> getGameStream(DocumentReference gameRef) {
    return gameRef.snapshots();
  }

  Future<Game> findActiveGameByRef(DocumentReference gameRef) {
    return _gameRepository.findActiveGameByRef(gameRef);
  }

  Future<void> changeGameState(DocumentReference gameRef, String gameState) async {
    Game game = await findActiveGameByRef(gameRef);
    game.gameState = gameState;
    return gameRef.set(game.toJson());
  }

  Future<String> getGameState(DocumentReference gameRef) async {
    Game game = await findActiveGameByRef(gameRef);
    return game.gameState;
  }

  Future<int> getGamePinByRef(DocumentReference gameRef) async {
    Game game = await findActiveGameByRef(gameRef);
    return game.pin;
  }
}
