import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/question_template.dart';

const QUESTIONS_COLLECTION = 'questions';

class QuestionRepository {
  final CollectionReference _repository = FirebaseFirestore.instance.collection(QUESTIONS_COLLECTION);

  Future<QuestionTemplate> findQuestionByNumber(questionNr) async {
    var snapshot = await _repository.doc(questionNr.toString()).get();
    return QuestionTemplate.fromSnapshot(snapshot);
  }

  Future<List<QuestionTemplate>> getAllQuestionTemplates() async {
    var snapshot = await _repository.get();
    List<QuestionTemplate> questions = snapshot.docs.map((snap) => QuestionTemplate.fromSnapshot(snap)).toList();
    return questions;
  }
}
