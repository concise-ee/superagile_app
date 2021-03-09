import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:superagile_app/services/timer_service.dart';
import 'package:superagile_app/ui/views/start_page.dart';
import 'package:superagile_app/utils/global_theme.dart';
import 'package:superagile_app/utils/labels.dart';

import 'agile_button.dart';

final _log = Logger((BackDialogAlert).toString());

class BackDialogAlert extends StatelessWidget {
  final TimerService timerService = TimerService();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(EXIT_TO_START_PAGE, textAlign: TextAlign.center, style: TextStyle(color: white)),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: Center(
            child: AgileButton(
              onPressed: () {
                timerService.cancelActivityTimer();
                _log.info('Participant clicked exit and answered YES, timer cancelled');
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
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
          child: Center(
            child: AgileButton(
              buttonTitle: NO,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}
