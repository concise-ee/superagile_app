import 'dart:async';

import 'package:superagile_app/services/player_service.dart';

Timer activityTimer;
const TIMER_DURATION = 10;
var _playerService = PlayerService();

startActivityTimer(playerRef) {
  if (activityTimer == null) {
    _playerService.sendLastActive(playerRef);
    activityTimer = Timer.periodic(Duration(seconds: TIMER_DURATION), (Timer t) {
      _playerService.sendLastActive(playerRef);
    });
  }
}
