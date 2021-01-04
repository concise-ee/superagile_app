import 'package:superagile_app/entities/player.dart';

bool areEqualByName(List<Player> activePlayers, List<Player> newActivePlayers) {
  if (activePlayers.length != newActivePlayers.length) {
    return false;
  }
  for (int i = 0; i < activePlayers.length; i++) {
    if (activePlayers[i].name != newActivePlayers[i].name) {
      return false;
    }
  }
  return true;
}
