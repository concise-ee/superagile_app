import 'package:cloud_firestore/cloud_firestore.dart';

const ZERO_MEANING = '0Meaning';
const ONE_MEANING = '1Meaning';
const TWO_MEANING = '2Meaning';
const THREE_MEANING = '3Meaning';
const SHORT_DESC = 'shortDescription';
const LONG_DESC = 'longDescription';
const QUESTION = 'question';
const TOPIC_NAME = 'topicName';
const TOPIC_NAME_SHORT = 'topicNameShort';

class QuestionTemplate {
  String zeroMeaning;
  String oneMeaning;
  String twoMeaning;
  String threeMeaning;
  String shortDesc;
  String longDesc;
  String question;
  String topicName;
  String topicNameShort;

  DocumentReference reference;

  QuestionTemplate(this.zeroMeaning, this.oneMeaning, this.twoMeaning, this.threeMeaning, this.shortDesc, this.longDesc,
      this.question, this.topicName, this.topicNameShort);

  factory QuestionTemplate.fromSnapshot(DocumentSnapshot snapshot) {
    var newQuestion = QuestionTemplate.fromJson(snapshot.data());
    newQuestion.reference = snapshot.reference;
    return newQuestion;
  }

  factory QuestionTemplate.fromJson(Map<String, dynamic> json) {
    return QuestionTemplate(json[ZERO_MEANING], json[ONE_MEANING], json[TWO_MEANING], json[THREE_MEANING],
        json[SHORT_DESC], json[LONG_DESC], json[QUESTION], json[TOPIC_NAME], json[TOPIC_NAME_SHORT]);
  }

  @override
  String toString() {
    return '${runtimeType}{$ZERO_MEANING: $zeroMeaning, $ONE_MEANING: $oneMeaning, $TWO_MEANING: $twoMeaning, '
        '$THREE_MEANING: $threeMeaning, $SHORT_DESC: $shortDesc, $LONG_DESC: $longDesc, $QUESTION: '
        '$question, $TOPIC_NAME: $topicName, $TOPIC_NAME_SHORT: $topicNameShort, reference: $reference}';
  }
}
