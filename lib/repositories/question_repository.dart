import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/question_template.dart';

const QUESTIONS_COLLECTION = 'questions';

class QuestionRepository {
  final CollectionReference _repository = FirebaseFirestore.instance.collection(QUESTIONS_COLLECTION);

  Future<QuestionTemplate> findQuestionByNumber(questionNr) async {
    var snapshot = await _repository.doc(questionNr.toString()).get();
    return QuestionTemplate.fromSnapshot(snapshot);
  }

  Future<Map<int, String>> getAllQuestionTopics() async {
    var snapshot = await _repository.get();
    Map<int, String> topicsByNumber = {};
    snapshot.docs.forEach((element) {
      var topicNumber = int.parse(element.id, onError: (source) => 0);
      // Temporary condition until we can delete the old questions doc
      if (topicNumber > 0) {
        topicsByNumber[topicNumber] = element.get('topic_name');
      }
    });
    return topicsByNumber;
  }
}
