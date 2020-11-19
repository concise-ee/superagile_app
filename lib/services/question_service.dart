import 'package:superagile_app/entities/question.dart';
import 'package:superagile_app/repositories/question_repository.dart';

class QuestionService {
  final QuestionRepository _questionRepository = QuestionRepository();

  Future<Question> findQuestionByNumber(questionNr) {
    return _questionRepository.findQuestionByNumber(questionNr);
  }
}