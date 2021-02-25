import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateAvailable extends StatelessWidget {
  UpdateAvailable({@required this.updateInfo});

  final AppUpdateInfo updateInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(50),
        child: Column(children: [
          Center(
            child: Text('Update is available: $updateInfo. Please update app to continue.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          ),
          Spacer(flex: 1),
          RaisedButton(
              child: Text('Update app'),
              onPressed: () {
                InAppUpdate.performImmediateUpdate();
              }),
        ]));
  }
}
