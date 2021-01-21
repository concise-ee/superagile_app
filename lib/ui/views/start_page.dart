import 'package:flutter/material.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/ui/views/host_start_page.dart';
import 'package:superagile_app/ui/views/player_start_page.dart';
import 'package:superagile_app/utils/labels.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
    child:
      Scaffold(
      appBar: AppBar(title: Text(HASH_SUPERAGILE), automaticallyImplyLeading: false),
      body: _buildBody(context),
    ));
  }

  Widget _buildBody(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
          ],
        ));
  }
}
