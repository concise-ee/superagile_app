import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/entities/score.dart';

const PIN = 'pin';
const IS_ACTIVE = 'isActive';
const QUESTION = 'question';

const GAMES_COLLECTION = 'games';
const PARTICIPANTS_SUB_COLLECTION = 'participants';
const SCORES_SUB_COLLECTION = 'scores';

class GameRepository {
  final CollectionReference _repository = FirebaseFirestore.instance.collection(GAMES_COLLECTION);

  Stream<QuerySnapshot> getGamesStream() {
    return _repository.snapshots();
  }

  Stream<DocumentSnapshot> getGameStream(DocumentReference gameRef) {
    return gameRef.snapshots();
  }

  Stream<QuerySnapshot> getScoresStream(DocumentReference participantRef) {
    return participantRef.collection(SCORES_SUB_COLLECTION).snapshots();
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

  Future<void> setScore(DocumentReference participantRef, Score score) {
    return participantRef.collection(SCORES_SUB_COLLECTION).doc(score.question.toString()).set(score.toJson());
  }

  Future<QuestionScores> findScoresForQuestion(DocumentReference gameRef, int questionNumber) async {
    QuerySnapshot participantsSnap = await gameRef.collection(PARTICIPANTS_SUB_COLLECTION).get();
    var scores = await buildScores(participantsSnap, questionNumber);
    return new QuestionScores(scores[null], scores[0], scores[1], scores[2], scores[3]);
  }

  Future<Map<int, List<String>>> buildScores(QuerySnapshot querySnapshot, int questionNumber) async {
    Map<int, List<String>> scores = {null: [], 0: [], 1: [], 2: [], 3: []};
    await Future.forEach(querySnapshot.docs, (participantSnap) async {
      QuerySnapshot scoreSnaps = await participantSnap.reference
          .collection(SCORES_SUB_COLLECTION)
          .where(QUESTION, isEqualTo: questionNumber)
          .get();
      if (!scoreSnaps.docs.isEmpty) {
        var score = Score.fromSnapshot(scoreSnaps.docs.single);
        var participant = Participant.fromSnapshot(participantSnap);
        scores[score.score].add(participant.name);
      }
    });
    return scores;
  }

  void deleteScore(DocumentReference participantRef, int questionNr) async {
    QuerySnapshot score =
        await participantRef.collection(SCORES_SUB_COLLECTION).where(QUESTION, isEqualTo: questionNr).get();
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
