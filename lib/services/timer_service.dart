import 'dart:async';

import 'package:logging/logging.dart';
import 'package:superagile_app/services/participant_service.dart';

const TIMER_DURATION = 10;
final _log = Logger((TimerService).toString());

class TimerService {
  final _participantService = ParticipantService();
  static Timer _activityTimer;

  void startActivityTimer(participantRef) {
    if (_activityTimer == null || !_activityTimer.isActive) {
      _log.info('${participantRef} timer ${_activityTimer}, new activityTimer started');
      _participantService.sendLastActive(participantRef);
      _activityTimer = Timer.periodic(Duration(seconds: TIMER_DURATION), (Timer t) {
        _participantService.sendLastActive(participantRef);
      });
    }
  }

  void cancelActivityTimer() {
    _activityTimer.cancel();
  }
}
