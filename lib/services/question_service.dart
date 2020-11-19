import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/question.dart';
import 'package:superagile_app/entities/score.dart';
import 'package:superagile_app/repositories/game_repository.dart';
import 'package:superagile_app/repositories/question_repository.dart';

class QuestionService {
  final QuestionRepository _questionRepository = QuestionRepository();
  final GameRepository _gameRepository = GameRepository();

  Future<void> saveScore(Score score, DocumentReference playerRef, DocumentReference gameRef) async {
    _gameRepository.addScore(playerRef, gameRef, score);
  }

  Future<Question> findQuestionByNumber(questionNr) async {
    return _questionRepository.findQuestionByNumber(questionNr);
  }
}