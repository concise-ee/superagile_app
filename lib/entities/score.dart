import 'package:cloud_firestore/cloud_firestore.dart';

const QUESTION = 'question';
const SCORE = 'score';
const PLAYER_REF_ID = 'playerRefId';

class Score {
  int question;
  int score;
  String playerRefId;
  DocumentReference reference;

  Score(this.question, this.score, this.playerRefId);

  factory Score.fromSnapshot(DocumentSnapshot snapshot) {
    var newScore = Score.fromJson(snapshot.data());
    newScore.reference = snapshot.reference;
    return newScore;
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(json[QUESTION], json[SCORE], json[PLAYER_REF_ID]);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      QUESTION: question,
      SCORE: score,
      PLAYER_REF_ID: playerRefId,
    };
  }

  @override
  String toString() {
    return 'Score{$QUESTION: $question, $SCORE: $score, $PLAYER_REF_ID: $playerRefId}';
  }
}
