import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';

const GAMES_COLLECTION = 'games';
const PLAYERS_SUB_COLLECTION = 'players';

class GameRepository {
  final CollectionReference _repository =
      FirebaseFirestore.instance.collection(GAMES_COLLECTION);

  Stream<QuerySnapshot> getGamesStream() {
    return _repository.snapshots();
  }

  Stream<QuerySnapshot> getGamePlayersStream(DocumentReference gameRef) {
    return gameRef.collection(PLAYERS_SUB_COLLECTION).snapshots();
  }

  Future<Game> addGame(Game game) async {
    var gameRef = await _repository.add(game.toJson());
    game.reference = gameRef;
    return game;
  }

  Future<Game> findGameByPin(int pin) async {
    QuerySnapshot result = await _repository.where('pin', isEqualTo: pin).get();
    return Game.fromSnapshot(result.docs.single);
  }

  Future<List<Player>> findGamePlayers(DocumentReference gameRef) async {
    QuerySnapshot playersSnap = await gameRef.collection(PLAYERS_SUB_COLLECTION).get();
    return playersSnap.docs.map((snap) => Player.fromSnapshot(snap)).toList();
  }

  addGamePlayer(DocumentReference gameRef, Player player) {
    CollectionReference players = gameRef.collection(PLAYERS_SUB_COLLECTION);
    players.add(player.toJson());
  }

  updateGamePlayer(DocumentReference gameRef, Player player) {
    gameRef
        .collection(PLAYERS_SUB_COLLECTION)
        .doc(player.reference.id)
        .update(player.toJson());
  }
}
