import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/utils/labels.dart';
import 'package:url_launcher/url_launcher.dart';

class QuestionMarkButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
        fit: BoxFit.fitWidth,
        child: IconButton(
          icon: Icon(Icons.help),
          padding: EdgeInsets.symmetric(horizontal: 200.0),
          color: Colors.yellowAccent,
          iconSize: 600.0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => FullScreenDialog(),
                fullscreenDialog: true,
              ),
            );
          },
        ));
  }
}

class FullScreenDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(HASH_SUPERAGILE),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsets.all(15.0),
                            child: Text(
                              WHY,
                              style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontSize: 28,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.bold),
                            )),
                      )),
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
                          padding: EdgeInsets.all(20),
                          child: Text(APPROACH,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
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
                            SUPERAGILE_IS_DESIGNED,
                            style: TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 1.5),
                          )),
                    ),
                  ),
                ],
              ),
              Container(
                child: new Image.asset('lib/assets/3426525.png'),
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
                            NOT_A_PROCESS,
                            style: TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 1.5),
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
                            style: TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 1.5),
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
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center)),
                    ),
                  ),
                ],
              ),
              Container(
                child: new Image.asset('lib/assets/2888960.png'),
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
                            style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.5),
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
                              const urlBlog = 'https://concise.ee/blog/';
                              _launchURL(urlBlog);
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
                              const urlEbook = 'https://concise.ee/superagile';
                              _launchURL(urlEbook);
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
}

_launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}
