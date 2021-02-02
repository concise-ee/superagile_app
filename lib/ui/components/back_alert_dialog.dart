import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:superagile_app/services/timer_service.dart';
import 'package:superagile_app/ui/views/start_page.dart';
import 'package:superagile_app/utils/labels.dart';

import 'agile_button.dart';

final _log = Logger((BackDialogAlert).toString());

class BackDialogAlert extends StatelessWidget {
  final TimerService timerService = TimerService();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(ARE_YOU_SURE),
      content: Text(EXIT_TO_START_PAGE),
      actions: [
        AgileButton(
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
