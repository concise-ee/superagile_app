import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/entities/score.dart';

const PIN = 'pin';
const IS_ACTIVE = 'isActive';
const QUESTION = 'question';

const GAMES_COLLECTION = 'games';
const PLAYERS_SUB_COLLECTION = 'players';
const SCORES_SUB_COLLECTION = 'scores';

class GameRepository {
  final CollectionReference _repository = FirebaseFirestore.instance.collection(GAMES_COLLECTION);

  Stream<QuerySnapshot> getGamesStream() {
    return _repository.snapshots();
  }

  Stream<DocumentSnapshot> getGameStream(DocumentReference gameRef) {
    return gameRef.snapshots();
  }

  Stream<QuerySnapshot> getScoresStream(DocumentReference playerRef) {
    return playerRef.collection(SCORES_SUB_COLLECTION).snapshots();
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

  Future<void> setScore(DocumentReference playerRef, Score score) {
    return playerRef.collection(SCORES_SUB_COLLECTION).doc('${score.question}').set(score.toJson());
  }

  Future<QuestionScores> findScoresForQuestion(DocumentReference gameRef, int questionNumber) async {
    QuerySnapshot playersSnap = await gameRef.collection(PLAYERS_SUB_COLLECTION).get();
    var scores = await buildScores(playersSnap, questionNumber);
    return new QuestionScores(scores[null], scores[0], scores[1], scores[2], scores[3]);
  }

  Future<Map<int, List<String>>> buildScores(QuerySnapshot querySnapshot, int questionNumber) async {
    Map<int, List<String>> scores = {null: [], 0: [], 1: [], 2: [], 3: []};
    await Future.forEach(querySnapshot.docs, (playerSnap) async {
      QuerySnapshot scoreSnaps =
          await playerSnap.reference.collection(SCORES_SUB_COLLECTION).where(QUESTION, isEqualTo: questionNumber).get();
      if (!scoreSnaps.docs.isEmpty) {
        var score = Score.fromSnapshot(scoreSnaps.docs.single);
        var player = Player.fromSnapshot(playerSnap);
        scores[score.score].add(player.name);
      }
    });
    return scores;
  }

  void deleteScore(DocumentReference playerRef, int questionNr) async {
    QuerySnapshot score =
        await playerRef.collection(SCORES_SUB_COLLECTION).where(QUESTION, isEqualTo: questionNr).get();
    score.docs.single.reference.delete();
  }

  void changeGameState(DocumentReference gameRef, String gameState) async {
    Game game = await findActiveGameByRef(gameRef);
    game.gameState = gameState;
    gameRef.set(game.toJson());
  }

  Future<void> setAgreedScores(DocumentReference gameRef, int agreedScore, int questionNr) async {
    DocumentSnapshot gameSnap = await gameRef.get();
    Game game = Game.fromSnapshot(gameSnap);
    game.agreedScores[questionNr.toString()] = agreedScore;
    return gameRef.set(game.toJson());
  }
}
