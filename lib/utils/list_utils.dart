import 'package:superagile_app/entities/participant.dart';

bool areEqualByName(List<Participant> activeParticipants, List<Participant> newActiveParticipants) {
  if (activeParticipants.length != newActiveParticipants.length) {
    return false;
  }
  for (int i = 0; i < activeParticipants.length; i++) {
    if (activeParticipants[i].name != newActiveParticipants[i].name) {
      return false;
    }
  }
  return true;
}
