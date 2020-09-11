import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/pages/game.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('#superagile')),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(25),
        child: ListView(
          children: [
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Enter PIN'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(hintText: 'Your name'),
            ),
            RaisedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Firestore.instance
                      .collection("players")
                      .add({"name": _nameController.text});
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      int pin = _pinController.text.isNotEmpty
                          ? int.parse(_pinController.text)
                          : null;
                      return GamePage(pin);
                    }),
                  );
                },
                child: Text("PLAY")),
          ],
        ));
  }
}
