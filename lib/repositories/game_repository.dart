import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/score.dart';

const PIN = 'pin';
const IS_ACTIVE = 'isActive';

const GAMES_COLLECTION = 'games';
const PLAYERS_SUB_COLLECTION = 'players';
const SCORES_SUB_COLLECTION = 'scores';

class GameRepository {
  final CollectionReference _repository = FirebaseFirestore.instance.collection(GAMES_COLLECTION);

  Stream<QuerySnapshot> getGamesStream() {
    return _repository.snapshots();
  }

  Stream<QuerySnapshot> getGamePlayersStream(DocumentReference gameRef) {
    return gameRef.collection(PLAYERS_SUB_COLLECTION).snapshots();
  }

  Future<DocumentReference> addGame(Game game) {
    return _repository.add(game.toJson());
  }

  Future<Game> findActiveGameByPin(int pin) async {
    var snapshot = await _repository.where(PIN, isEqualTo: pin).where(IS_ACTIVE, isEqualTo: true).get();
    return Game.fromSnapshot(snapshot.docs.single);
  }

  Future<DocumentReference> findActiveGameRefByPin(int pin) async {
    var snapshot = await _repository.where(PIN, isEqualTo: pin).where(IS_ACTIVE, isEqualTo: true).get();
    return snapshot.docs.single.reference;
  }

  Future<Game> findActiveGameByRef(DocumentReference gameRef) async {
    var snapshot = await _repository.doc(gameRef.id).get();
    return Game.fromSnapshot(snapshot);
  }

  Future<Game> findActiveGameByPinNullable(int pin) async {
    var snapshot = await _repository.where(PIN, isEqualTo: pin).where(IS_ACTIVE, isEqualTo: true).get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return Game.fromSnapshot(snapshot.docs.single);
  }

  Future<List<Player>> findGamePlayers(DocumentReference gameRef) async {
    var playersSnap = await gameRef.collection(PLAYERS_SUB_COLLECTION).get();
    return playersSnap.docs.map((snap) => Player.fromSnapshot(snap)).toList();
  }

  Future<DocumentReference> addGamePlayer(DocumentReference gameRef, Player player) {
    var players = gameRef.collection(PLAYERS_SUB_COLLECTION);
    return players.add(player.toJson());
  }

  void updateGamePlayer(DocumentReference gameRef, Player player) {
    gameRef.collection(PLAYERS_SUB_COLLECTION).doc(player.reference.id).update(player.toJson());
  }

  void addScore(DocumentReference gameRef, DocumentReference playerRef, Score score) {
    var scores = gameRef.collection(PLAYERS_SUB_COLLECTION).doc(playerRef.id).collection(SCORES_SUB_COLLECTION);
    scores.add(score.toJson());
  }
}
