import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:superagile_app/repositories/game_repository.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/question_answers_section.dart';
import 'package:superagile_app/utils/labels.dart';

class QuestionResultsPage extends StatefulWidget {
  @override
  _QuestionResultsPageState createState() => _QuestionResultsPageState();
}

class _QuestionResultsPageState extends State<QuestionResultsPage> {
  final GameRepository _gameRepository = GameRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(HASH_SUPERAGILE)),
        body: Column(
          children: [
            Expanded(
                child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        QuestionAnswersSection(answerNumber: 3),
                        QuestionAnswersSection(answerNumber: 2),
                        QuestionAnswersSection(answerNumber: 1),
                        QuestionAnswersSection(answerNumber: 0),
                      ],
                    ))),
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              height: 160.0,
              child: Column(
                children: [
                  Text(SAME_ANSWER, textAlign: TextAlign.center),
                  Spacer(flex: 1),
                  AgileButton(
                    buttonTitle: CHANGE_ANSWER,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
