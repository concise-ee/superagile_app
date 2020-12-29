import 'package:superagile_app/entities/question_template.dart';
import 'package:superagile_app/repositories/question_repository.dart';

class QuestionService {
  final QuestionRepository _questionRepository = QuestionRepository();

  Future<QuestionTemplate> findQuestionByNumber(questionNr) {
    return _questionRepository.findQuestionByNumber(questionNr);
  }
}
