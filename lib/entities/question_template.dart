import 'package:cloud_firestore/cloud_firestore.dart';

const ZERO_MEANING = '0_meaning';
const ONE_MEANING = '1_meaning';
const TWO_MEANING = '2_meaning';
const THREE_MEANING = '3_meaning';
const SHORT_DESC = 'short_description';
const LONG_DESC = 'long_description';
const QUESTION = 'question';
const TOPIC_NAME = 'topic_name';

class QuestionTemplate {
  String zeroMeaning;
  String oneMeaning;
  String twoMeaning;
  String threeMeaning;
  String shortDesc;
  String longDesc;
  String question;
  String topicName;

  DocumentReference reference;

  QuestionTemplate(this.zeroMeaning, this.oneMeaning, this.twoMeaning, this.threeMeaning, this.shortDesc, this.longDesc,
      this.question, this.topicName);

  factory QuestionTemplate.fromSnapshot(DocumentSnapshot snapshot) {
    var newQuestion = QuestionTemplate.fromJson(snapshot.data());
    newQuestion.reference = snapshot.reference;
    return newQuestion;
  }

  factory QuestionTemplate.fromJson(Map<String, dynamic> json) {
    return QuestionTemplate(json[ZERO_MEANING], json[ONE_MEANING], json[TWO_MEANING], json[THREE_MEANING], json[SHORT_DESC],
        json[LONG_DESC], json[QUESTION], json[TOPIC_NAME]);
  }

  @override
  String toString() {
    return 'Question{$ZERO_MEANING: $zeroMeaning, $ONE_MEANING: $oneMeaning, $TWO_MEANING: $twoMeaning, '
        '$THREE_MEANING: $threeMeaning, $SHORT_DESC: $shortDesc, $LONG_DESC: $longDesc, $QUESTION: '
        '$question, $TOPIC_NAME: $topicName, reference: $reference}';
  }
}
