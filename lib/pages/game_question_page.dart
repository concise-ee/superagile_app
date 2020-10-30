import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:superagile_app/Resources/AgileButton.dart';
import 'package:superagile_app/constants/labels.dart';

class GameQuestionPage extends StatefulWidget {
  final int question_nr;

  GameQuestionPage(this.question_nr);

  @override
  _GameQuestionPage createState() => _GameQuestionPage();
}

class _GameQuestionPage extends State<GameQuestionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(HASH_SUPERAGILE)),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                            fit: FlexFit.loose,
                            flex: 1,
                            child: Container(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    '1',
                                    style: TextStyle(color: Colors.white, fontSize: 110, letterSpacing: 1.5),
                                  )),
                            )),
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'How comfortable do you feel about releasing without any manual testing?',
                                  style: TextStyle(color: Colors.white, fontSize: 18, height: 1.2, letterSpacing: 1.5),
                                )),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                '0 - Lorem Ipsum is simply dummy text of',
                                style: TextStyle(color: Colors.yellowAccent, fontSize: 18, letterSpacing: 1.5),
                              )),
                        )),
                    Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                '1 - the printing and typesetting industry.',
                                style: TextStyle(color: Colors.yellowAccent, fontSize: 18, letterSpacing: 1.5),
                              )),
                        )),
                    Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                "2 - Lorem Ipsum has been the industry's standard dummy",
                                style: TextStyle(color: Colors.yellowAccent, fontSize: 18, letterSpacing: 1.5),
                              )),
                        )),
                    Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text(
                                '3 - text ever since the 1500s, when an unknown printer took a',
                                style: TextStyle(color: Colors.yellowAccent, fontSize: 18, letterSpacing: 1.5),
                              )),
                        )),
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 1,
                      child: Container(
                          alignment: Alignment.center,
                          child: Padding(
                              padding: EdgeInsets.only(
                                left: 5,
                                right: 5,
                                top: 25,
                                bottom: 25,
                              ),
                              child: Text(
                                'dui sit amet commodo dictum, lectus tortor faubicuspurus, nec maximus nibh neque',
                                style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 1.5),
                                textAlign: TextAlign.center,
                              ))),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              'Contrary to popular belief, Lorem Ipsum '
                              'is not simply random text. It has roots in '
                              'a piece of classical Latin literature from 45 BC,'
                              ' making it over 2000 years old. Richard McClintock, '
                              'a Latin professor at Hampden-Sydney College in Virginia, '
                              'looked up one of the more obscure Latin words, consectetur, from'
                              ' a Lorem Ipsum passage, and going through the cites of the word in '
                              'classical literature, discovered the undoubtable source. Lorem Ipsum '
                              'comes from sections 1.10.32 and 1.10.33 of de Finibus Bonorum et Malorum'
                              ' (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book '
                              'is a treatise on the theory of ethics, very popular during the Renaissance.'
                              ' The first line of Lorem Ipsum, Lorem ipsum dolor sit amet.., comes from a '
                              "line in section 1.10.32.",
                              style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.5),
                            )),
                      ),
                    ),
                  ],
                ))),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: AgileButton(
                buttonTitle: ZERO,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return null;
                    }),
                  );
                },
              ),
            ),
            Expanded(
              child: AgileButton(
                buttonTitle: ONE,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return null;
                    }),
                  );
                },
              ),
            ),
            Expanded(
              child: AgileButton(
                buttonTitle: TWO,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return null;
                    }),
                  );
                },
              ),
            ),
            Expanded(
              child: AgileButton(
                buttonTitle: THREE,
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return null;
                    }),
                  );
                },
              ),
            )
          ],
        )
      ],
    );
  }
}
