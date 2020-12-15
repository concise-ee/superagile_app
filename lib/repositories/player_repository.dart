import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/player.dart';

const PLAYERS_SUB_COLLECTION = 'players';

class PlayerRepository {
  Stream<QuerySnapshot> getGamePlayersStream(DocumentReference gameRef) {
    return gameRef.collection(PLAYERS_SUB_COLLECTION).snapshots();
  }

  Future<List<Player>> findGamePlayers(DocumentReference gameRef) async {
    var playersSnap = await gameRef.collection(PLAYERS_SUB_COLLECTION).get();
    return playersSnap.docs.map((snap) => Player.fromSnapshot(snap)).toList();
  }

  Future<DocumentReference> addGamePlayer(
      DocumentReference gameRef, Player player) {
    var players = gameRef.collection(PLAYERS_SUB_COLLECTION);
    return players.add(player.toJson());
  }

  void updateGamePlayer(Player player) async {
    player.reference.update(player.toJson());
  }

  Future<Player> findGamePlayerByRef(DocumentReference playerRef) async {
    var playerSnap = await playerRef.get();
    return Player.fromSnapshot(playerSnap);
  }
}
