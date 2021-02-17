import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/utils/labels.dart';

class QuestionMarkButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
        fit: BoxFit.fitWidth,
        child: IconButton(
          icon: Icon(Icons.help_outline),
          padding: EdgeInsets.symmetric(horizontal: 200.0),
          color: Colors.yellowAccent,
          iconSize: 300.0,
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
      body: Center(
        child: Text("Full-screen dialog"),
      ),
    );
  }
}
