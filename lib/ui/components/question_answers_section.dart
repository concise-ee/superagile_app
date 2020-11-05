import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class QuestionAnswersSection extends StatelessWidget {
  QuestionAnswersSection({@required this.answerNumber});

  final int answerNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 25),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
            bottom: BorderSide(width: 1.0, color: Color(0xFFFFFFFFFF)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              answerNumber.toString(),
              style: TextStyle(color: Colors.white, fontSize: 100, fontWeight: FontWeight.w600),
            ),
            Column(children: [
              Text('firstname', style: TextStyle(color: Colors.white, fontSize: 14, height: 3, letterSpacing: 2)),
              Text('firstname', style: TextStyle(color: Colors.white, fontSize: 14, height: 3, letterSpacing: 2)),
              Text('firstname', style: TextStyle(color: Colors.white, fontSize: 14, height: 3, letterSpacing: 2)),
              Text('firstname', style: TextStyle(color: Colors.white, fontSize: 14, height: 3, letterSpacing: 2)),
            ])
          ],
        ));
  }
}
