import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/repositories/participant_repository.dart';

const ACTIVITY_INTERVAL = 15;

class ParticipantService {
  final ParticipantRepository _participantRepository = ParticipantRepository();

  List<Participant> findActiveParticipants(List<QueryDocumentSnapshot> snaps) {
    return snaps
        .map((participantSnap) => Participant.fromSnapshot(participantSnap))
        .where((participant) => participant.isPlayingAlong == true)
        .where((participant) => DateTime.parse(participant.lastActive)
            .isAfter(DateTime.now().subtract(Duration(seconds: ACTIVITY_INTERVAL))))
        .toList();
  }

  Future<bool> checkIfParticipantIsActive(DocumentReference participantRef) async {
    var participant = await _participantRepository.findParticipantByRef(participantRef);
    return DateTime.parse(participant.lastActive)
        .isAfter(DateTime.now().subtract(Duration(seconds: ACTIVITY_INTERVAL)));
  }

  void sendLastActive(DocumentReference participantRef) async {
    Participant participant = await _participantRepository.findParticipantByRef(participantRef);
    participant.lastActive = DateTime.now().toString();
    _participantRepository.updateParticipant(participant);
  }

  Future<DocumentReference> addParticipant(DocumentReference gameRef, Participant participant) {
    return _participantRepository.addParticipant(gameRef, participant);
  }

  Future<List<Participant>> findParticipants(DocumentReference gameRef) {
    return _participantRepository.findParticipants(gameRef);
  }

  Future<List<Participant>> findActiveGameParticipants(DocumentReference gameRef) async {
    List<Participant> participants = await _participantRepository.findParticipants(gameRef);
    participants.sort((a, b) => (a.name).compareTo(b.name));
    return participants
        .where((participant) => DateTime.parse(participant.lastActive)
            .isAfter(DateTime.now().subtract(Duration(seconds: ACTIVITY_INTERVAL))))
        .toList();
  }

  Stream<QuerySnapshot> getParticipantsStream(DocumentReference gameRef) {
    return _participantRepository.getParticipantsStream(gameRef);
  }

  Future<Participant> findGameParticipantByRef(DocumentReference participantRef) async {
    return await _participantRepository.findParticipantByRef(participantRef);
  }

  Future<DocumentReference> findParticipantRefByName(DocumentReference gameRef, String name) {
    return _participantRepository.findParticipantRefByName(gameRef, name);
  }
}
