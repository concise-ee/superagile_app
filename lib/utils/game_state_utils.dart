class GameState {
  static const String QUESTION = 'question';
  static const String QUESTION_RESULTS = 'results';
  static const String CONGRATULATIONS = 'congratulations';
}

const String STATE_NUMBER_DELIMITER = '_';

int parseSequenceNumberFromGameState(String gameState) => int.parse(gameState.split(STATE_NUMBER_DELIMITER).last);
