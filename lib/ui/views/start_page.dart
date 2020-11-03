import 'package:flutter/material.dart';
import 'package:superagile_app/ui/views/game_question_page.dart';
import 'package:superagile_app/ui/views/question_results_page.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/views/host_start_page.dart';
import 'package:superagile_app/ui/views/player_start_page.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(HASH_SUPERAGILE)),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
            ),
            Spacer(
              flex: 2,
            ),
            Flexible(
              flex: 5,
              child: AgileButton(
                buttonTitle: HOST,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return HostStartPage();
                    }),
                  );
                },
              ),
            ),
            Spacer(
              flex: 1,
            ),
            Flexible(
              flex: 5,
              child: AgileButton(
                buttonTitle: JOIN,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return PlayerStartPage();
                    }),
                  );
                },
              ),
            ),
            Spacer(
              flex: 2,
            ),
            Flexible(
              flex: 5,
              child: AgileButton(
                buttonTitle: 'Question results',
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return QuestionResultsPage();
                    }),
                  );
                },
              ),
            ),
            Flexible(
              flex: 5,
              child: AgileButton(
                buttonTitle: 'Question',
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return GameQuestionPage(1);
                    }),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
