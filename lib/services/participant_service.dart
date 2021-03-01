import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/participant.dart';
import 'package:superagile_app/repositories/participant_repository.dart';

const ACTIVITY_INTERVAL = 15;

const PARTICIPANT_REF_ID = 'participantRefId';

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
    var participant = await findParticipantByRef(participantRef);
    return DateTime.parse(participant.lastActive)
        .isAfter(DateTime.now().subtract(Duration(seconds: ACTIVITY_INTERVAL)));
  }

  void sendLastActive(DocumentReference participantRef) async {
    participantRef.update({LAST_ACTIVE: DateTime.now().toString()});
  }

  Future<DocumentReference> addParticipant(DocumentReference gameRef, Participant participant) async {
    String generatedRefId = _participantRepository.generateDocRefId();
    var participantJson = participant.toJson();
    participantJson[PARTICIPANT_REF_ID] = generatedRefId;
    DocumentReference doc = gameRef.collection(PARTICIPANTS_SUB_COLLECTION).doc(generatedRefId);
    await doc.set(participantJson);
    return doc;
  }

  Future<List<Participant>> findParticipants(DocumentReference gameRef) async {
    var participantsSnap = await gameRef.collection(PARTICIPANTS_SUB_COLLECTION).get();
    return participantsSnap.docs.map((snap) => Participant.fromSnapshot(snap)).toList();
  }

  Future<List<Participant>> findActiveGameParticipants(DocumentReference gameRef) async {
    List<Participant> participants = await findParticipants(gameRef);
    participants.sort((a, b) => (a.name).compareTo(b.name));
    return participants
        .where((participant) => DateTime.parse(participant.lastActive)
            .isAfter(DateTime.now().subtract(Duration(seconds: ACTIVITY_INTERVAL))))
        .toList();
  }

  Stream<QuerySnapshot> getParticipantsStream(DocumentReference gameRef) {
    return gameRef.collection(PARTICIPANTS_SUB_COLLECTION).snapshots();
  }

  Future<Participant> findGameParticipantByRef(DocumentReference participantRef) async {
    return await findParticipantByRef(participantRef);
  }

  Future<DocumentReference> findParticipantRefByName(DocumentReference gameRef, String name) async {
    var participant = await gameRef.collection(PARTICIPANTS_SUB_COLLECTION).where(NAME, isEqualTo: name).get();
    if (participant.docs.isEmpty) {
      return null;
    }
    return participant.docs.single.reference;
  }

  Future<Participant> findParticipantByRef(DocumentReference participantRef) async {
    var participantSnap = await participantRef.get();
    return Participant.fromSnapshot(participantSnap);
  }

  Future<QuerySnapshot> getParticipants(DocumentReference gameRef) {
    return gameRef.collection(PARTICIPANTS_SUB_COLLECTION).get();
  }

  double calculateCircleFill(List<Participant> activeParticipants, List<String> answeredParticipantNames) {
    List<String> activeParticipantNames = activeParticipants.map((p) => p.name).toList();
    int activeAnswers = answeredParticipantNames.where((p) => activeParticipantNames.contains(p)).length;
    return activeAnswers / activeParticipants.length;
  }
}
