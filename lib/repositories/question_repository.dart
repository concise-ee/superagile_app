import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/question.dart';

const QUESTIONS_COLLECTION = 'questions';
const QUESTION_DOC_REFERENCE = 'Z0n947Uqvg2R3gH74kyc';

class QuestionRepository {
  final CollectionReference _repository = FirebaseFirestore.instance.collection(QUESTIONS_COLLECTION);

  Future<Question> findQuestionByNumber(questionNr) async {
    var snapshot = await _repository.doc(QUESTION_DOC_REFERENCE).collection(questionNr.toString()).get();
    return Question.fromSnapshot(snapshot.docs.single);
  }
}
