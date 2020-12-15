class QuestionScores {
  List<String> answeredNull;
  List<String> answered0;
  List<String> answered1;
  List<String> answered2;
  List<String> answered3;

  QuestionScores(this.answeredNull, this.answered0, this.answered1, this.answered2, this.answered3);

  @override
  String toString() {
    return 'QuestionScores{answeredNull: $answeredNull, answered0: $answered0, answered1: $answered1, answered2: $answered2, answered3: $answered3}';
  }
}
