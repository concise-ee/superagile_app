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
            bottom: BorderSide(width: 1.0, color: secondaryColor),
          ),
        ),
        child: Row(children: [
          Text(
            answerNumber.toString(),
            style: TextStyle(color: Colors.white, fontSize: fontExtraExtraLarge),
          ),
          Expanded(
              child: Padding(
                  padding: EdgeInsets.only(left: 25),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: getFirstHalfOfParticipants()))),
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getSecondHalfOfParticipants(),
            ),
          )),
        ]));
  }

  List<Widget> getParticipantNameList() {
    return participantNames
        .map((item) => Container(
            child: Text(item,
                overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: fontSmall))))
        .toList();
  }

  List<Widget> getFirstHalfOfParticipants() {
    var participants = getParticipantNameList();
    return participants.sublist(0, (participants.length / 2).ceil());
  }

  List<Widget> getSecondHalfOfParticipants() {
    var participants = getParticipantNameList();
    return participants.sublist((participants.length / 2).ceil());
  }
}
