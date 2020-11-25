import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/question_scores.dart';
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

  void updateGamePlayer(Player player) async {
    player.reference.update(player.toJson());
  }

  Future<void> addScore(DocumentReference playerRef, Score score) {
    return playerRef.collection(SCORES_SUB_COLLECTION).add(score.toJson());
  }

  Future<Player> findGamePlayerByRef(DocumentReference playerRef) async {
    var playerSnap = await playerRef.get();
    return Player.fromSnapshot(playerSnap);
  }

  Future<QuestionScores> findScoresForQuestion(DocumentReference gameRef, int questionNumber) async {
    var scores = {0: [], 1: [], 2: [], 3: []};

    var querySnapshot = await gameRef.collection(PLAYERS_SUB_COLLECTION).get();
    querySnapshot.docs.forEach((doc) async {
      var snaps = await doc.reference.collection(SCORES_SUB_COLLECTION).where('question', isEqualTo: questionNumber).snapshots().first;
      var scoreVal = snaps.docs.first.data()['score'];
      var name = doc.data()['name'];
      scores[scoreVal].add(name);
    });
    QuestionScores scoresObj = new QuestionScores(scores[0], scores[1], scores[2], scores[3]);
    return scoresObj;
  }
}
