import 'dart:async';

import 'package:superagile_app/services/participant_service.dart';

Timer activityTimer;
const TIMER_DURATION = 10;
final _participantService = ParticipantService();

startActivityTimer(participantRef) {
  if (activityTimer == null) {
    _participantService.sendLastActive(participantRef);
    activityTimer = Timer.periodic(Duration(seconds: TIMER_DURATION), (Timer t) {
      _participantService.sendLastActive(participantRef);
    });
  }
}
