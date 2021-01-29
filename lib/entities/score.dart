import 'package:cloud_firestore/cloud_firestore.dart';

const QUESTION = 'question';
const SCORE = 'score';
const PARTICIPANT_REF_ID = 'participantRefId';

class Score {
  int question;
  int score;
  String participantRefId;
  DocumentReference reference;

  Score(this.question, this.score, this.participantRefId);

  factory Score.fromSnapshot(DocumentSnapshot snapshot) {
    var newScore = Score.fromJson(snapshot.data());
    newScore.reference = snapshot.reference;
    return newScore;
  }

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(json[QUESTION], json[SCORE], json[PARTICIPANT_REF_ID]);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      QUESTION: question,
      SCORE: score,
      PARTICIPANT_REF_ID: participantRefId,
    };
  }

  @override
  String toString() {
    return '${runtimeType}{$QUESTION: $question, $SCORE: $score, $PARTICIPANT_REF_ID: $participantRefId}';
  }
}
