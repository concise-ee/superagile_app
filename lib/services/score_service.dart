import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/entities/question_scores.dart';
import 'package:superagile_app/entities/score.dart';
import 'package:superagile_app/services/game_service.dart';
import 'package:superagile_app/services/participant_service.dart';

const SCORES_SUB_COLLECTION = 'scores';

class ScoreService {
  final _gameService = GameService();
  final _participantsService = ParticipantService();

  Future<void> setScore(
      DocumentReference participantRef, DocumentReference gameRef, int questionNr, String scoreValue) async {
    var score = Score(questionNr, scoreValue != null ? int.parse(scoreValue) : null, participantRef.id);
    return participantRef.collection(SCORES_SUB_COLLECTION).doc(score.question.toString()).set(score.toJson());
  }

  Stream<QuerySnapshot> getScoresStream(DocumentReference participantRef) {
    return participantRef.collection(SCORES_SUB_COLLECTION).snapshots();
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

  Future<QuestionScores> findScoresForQuestion(DocumentReference gameRef, int questionNumber) async {
    QuerySnapshot participantsSnap = await _participantsService.getParticipants(gameRef);
    var scores = await buildScores(participantsSnap, questionNumber);
    return QuestionScores(scores[null], scores[0], scores[1], scores[2], scores[3]);
  }

  List<String> getAnsweredParticipantNames(QuestionScores questionScores) {
    return questionScores.answeredNull +
        questionScores.answered0 +
        questionScores.answered1 +
        questionScores.answered2 +
        questionScores.answered3;
  }

  Future<void> deleteOldScore(DocumentReference participantRef, int questionNr) async {
    QuerySnapshot score =
        await participantRef.collection(SCORES_SUB_COLLECTION).where(QUESTION, isEqualTo: questionNr).get();
    return score.docs.single.reference.delete();
  }

  Future<void> setAgreedScore(DocumentReference gameRef, int agreedScore, int questionNr) async {
    DocumentSnapshot gameSnap = await gameRef.get();
    Game game = Game.fromSnapshot(gameSnap);
    game.agreedScores[questionNr.toString()] = agreedScore;
    return gameRef.set(game.toJson());
  }

  Future<Map<String, int>> getAgreedScores(DocumentReference gameRef) async {
    Game game = await _gameService.findActiveGameByRef(gameRef);
    return game.agreedScores;
  }

  Future<int> getAgreedScoreForQuestion(DocumentReference gameRef, int questionNr) async {
    Map<String, int> agreedScores = await getAgreedScores(gameRef);
    return agreedScores[questionNr.toString()];
  }
}
