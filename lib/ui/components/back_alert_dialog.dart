import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:superagile_app/ui/views/start_page.dart';
import 'package:superagile_app/utils/globals.dart';
import 'package:superagile_app/utils/labels.dart';

import 'agile_button.dart';

class BackDialogAlert extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(ARE_YOU_SURE),
      content: Text(EXIT_TO_START_PAGE),
      actions: [
        AgileButton(
          onPressed: () {
            activityTimer.cancel();
            Navigator.pop(context);
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
            Navigator.pop(context);
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
