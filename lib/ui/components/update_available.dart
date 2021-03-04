import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:superagile_app/ui/components/agile_button.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';

class UpdateAvailable extends StatelessWidget {
  UpdateAvailable({@required this.updateInfo});

  final AppUpdateInfo updateInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 25),
        child: Column(children: [
          Center(
            child: Text('Update is available: ${updateInfo.availableVersionCode}. Please update app to continue.',
                style: TextStyle(fontSize: fontMedium, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
          ),
          Spacer(flex: 1),
          AgileButton(
              buttonTitle: UPDATE_APP,
              onPressed: () {
                InAppUpdate.performImmediateUpdate();
              }),
        ]));
  }
}
