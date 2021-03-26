import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/components/curve_painter.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:superagile_app/utils/url_utils.dart';

class AboutPage extends StatelessWidget {
  static const urlEbook = 'https://concise.ee/superagile';
  static const urlBlog = 'https://concise.ee/blog';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: aboutPageBackgroundColor,
        appBar: AppBar(
          title: Text(HASH_SUPERAGILE),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.1),
                painter: CurvePainter(),
              )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      HOW,
                      style: TextStyle(color: black, fontSize: fontLarge, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Image.asset('lib/assets/how_to_play_label.png'),
              SizedBox(
                height: 20,
              ),
              buildTutorial(),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      WHY,
                      style: TextStyle(color: black, fontSize: fontLarge, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Image.asset('lib/assets/superagile_label.png'),
              SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: EdgeInsets.all(25),
                          child: Text(APPROACH,
                              style: TextStyle(color: black, fontSize: fontSmall, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: EdgeInsets.all(25),
                          child: Text(
                            SUPERAGILE_IS_DESIGNED,
                            style: TextStyle(color: black, fontSize: fontSmall),
                          )),
                    ),
                  ),
                ],
              ),
              Container(
                child: Image.asset('lib/assets/green_about_us_picture.png'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: EdgeInsets.all(25),
                          child: Text(
                            NOT_A_PROCESS,
                            style: TextStyle(color: black, fontSize: fontSmall),
                          )),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: EdgeInsets.all(25),
                          child: Text(
                            IN_THE_END,
                            style: TextStyle(color: black, fontSize: fontSmall),
                          )),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: EdgeInsets.only(
                            top: 40,
                            bottom: 50,
                            left: 30,
                            right: 30,
                          ),
                          child: Text(HONEST,
                              style: TextStyle(color: black, fontSize: fontSmall, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                    ),
                  ),
                ],
              ),
              Container(
                child: Image.asset('lib/assets/blue_about_us_picture.png'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                          padding: EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
                          child: Text(
                            READ_MORE,
                            style: TextStyle(color: black, fontSize: fontSmall),
                          )),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: AgileButton(
                            onPressed: () {
                              launchURL(urlBlog);
                            },
                            buttonTitle: BLOG),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: AgileButton(
                            onPressed: () {
                              launchURL(urlEbook);
                            },
                            buttonTitle: EBOOK),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }

  Widget buildTutorial() {
    return Container(
        padding: EdgeInsets.only(left: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Flexible(
                  fit: FlexFit.loose,
                  flex: 1,
                  child: Text(
                    '1.',
                    style: TextStyle(color: Colors.grey, fontSize: fontLarge),
                  )),
              Flexible(
                fit: FlexFit.loose,
                flex: 4,
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: EdgeInsets.only(left: 25, bottom: 5, top: 25, right: 25),
                      child: Text(
                        TUTORIAL_STEP_ONE,
                        style: TextStyle(color: black, fontSize: fontSmall),
                      )),
                ),
              ),
            ]),
            Row(
              children: [
                Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Text(
                      '2.',
                      style: TextStyle(color: Colors.grey, fontSize: fontLarge),
                    )),
                Flexible(
                  fit: FlexFit.loose,
                  flex: 4,
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                        padding: EdgeInsets.only(left: 25, bottom: 5, top: 25, right: 25),
                        child: Text(
                          TUTORIAL_STEP_TWO,
                          style: TextStyle(color: black, fontSize: fontSmall),
                        )),
                  ),
                ),
              ],
            ),
            Row(children: [
              Flexible(
                  fit: FlexFit.loose,
                  flex: 1,
                  child: Text(
                    '3.',
                    style: TextStyle(color: Colors.grey, fontSize: fontLarge),
                  )),
              Flexible(
                fit: FlexFit.loose,
                flex: 4,
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: EdgeInsets.only(left: 25, bottom: 5, top: 25, right: 25),
                      child: Text(
                        TUTORIAL_STEP_THREE,
                        style: TextStyle(color: black, fontSize: fontSmall),
                      )),
                ),
              ),
            ]),
            Row(
              children: [
                Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Text(
                      '4.',
                      style: TextStyle(color: Colors.grey, fontSize: fontLarge),
                    )),
                Flexible(
                  fit: FlexFit.loose,
                  flex: 4,
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                        padding: EdgeInsets.only(left: 25, bottom: 5, top: 25, right: 25),
                        child: Text(
                          TUTORIAL_STEP_FOUR,
                          style: TextStyle(color: black, fontSize: fontSmall),
                        )),
                  ),
                ),
              ],
            ),
            Row(children: [
              Flexible(
                  fit: FlexFit.loose,
                  flex: 1,
                  child: Text(
                    '5.',
                    style: TextStyle(color: Colors.grey, fontSize: fontLarge),
                  )),
              Flexible(
                fit: FlexFit.loose,
                flex: 4,
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: EdgeInsets.only(left: 25, bottom: 5, top: 25, right: 25),
                      child: Text(
                        TUTORIAL_STEP_FIVE,
                        style: TextStyle(color: black, fontSize: fontSmall),
                      )),
                ),
              ),
            ]),
            Row(
              children: [
                Flexible(
                    fit: FlexFit.loose,
                    flex: 1,
                    child: Text(
                      '6.',
                      style: TextStyle(color: Colors.grey, fontSize: fontLarge),
                    )),
                Flexible(
                  fit: FlexFit.loose,
                  flex: 4,
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                        padding: EdgeInsets.only(left: 25, bottom: 5, top: 25, right: 25),
                        child: Text(
                          TUTORIAL_STEP_SIX,
                          style: TextStyle(color: black, fontSize: fontSmall),
                        )),
                  ),
                ),
              ],
            )
          ],
        ));
  }
}
