import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/utils/global_theme.dart';

class QuestionAnswersSection extends StatelessWidget {
  QuestionAnswersSection({@required this.answerNumber, @required this.participantNames});

  final int answerNumber;
  final List<String> participantNames;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0, color: secondaryColor),
            bottom: BorderSide(width: 1.0, color: secondaryColor),
          ),
        ),
        child: Row(children: [
          Text(
            answerNumber.toString(),
            style: TextStyle(color: Colors.white, fontSize: 105),
          ),
          Padding(
            padding: EdgeInsets.only(left: 25),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: participantNames
                    .map((item) => Text(item, style: TextStyle(color: Colors.white, fontSize: 16)))
                    .toList()),
          ),
        ]));
  }
}
