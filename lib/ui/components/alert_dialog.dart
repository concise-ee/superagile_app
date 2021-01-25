import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/ui/views/start_page.dart';
import 'package:superagile_app/utils/globals.dart';
import 'package:superagile_app/utils/labels.dart';

import 'agile_button.dart';

class DialogAlert {
  Future<bool> onBackPressed(BuildContext context) {
    return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(ARE_YOU_SURE),
            content: Text(EXIT_TO_START_PAGE),
            actions: [
              AgileButton(
                onPressed: () {
                  activityTimer.cancel();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return StartPage();
                    }),
                  );
                },
                buttonTitle: YES,
              ),
              AgileButton(
                buttonTitle: NO,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ) ??
        null;
  }
}
