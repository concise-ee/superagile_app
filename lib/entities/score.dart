import 'package:cloud_firestore/cloud_firestore.dart';

const QUESTION = 'question';
const SCORE = 'score';

class Score {
  int question;
  int score;
  DocumentReference reference;

  Score(this.question, this.score);

  factory Score.fromSnapshot(DocumentSnapshot snapshot) {
    var newScore = Score.fromJson(snapshot.data());
    newScore.reference = snapshot.reference;
    return newScore;
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    var score = Score(json[QUESTION] as int, json[SCORE] as int);
    return score;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      QUESTION: question,
      SCORE: score,
    };
  }

  @override
  String toString() {
    return 'Score{$QUESTION: $question, $SCORE: $score}';
  }
}
