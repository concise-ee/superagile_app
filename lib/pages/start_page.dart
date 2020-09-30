import 'package:flutter/material.dart';
import 'package:superagile_app/constants/Labels.dart';
import 'package:superagile_app/pages/host_start_page.dart';
import 'package:superagile_app/pages/player_start_page.dart';

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
        child: ListView(
          children: [
            RaisedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return PlayerStartPage();
                    }),
                  );
                },
                child: Text(JOIN)),
            RaisedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return HostStartPage();
                    }),
                  );
                },
                child: Text(HOST)),
          ],
        ));
  }
}
