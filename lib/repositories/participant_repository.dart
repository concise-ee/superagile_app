import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/participant.dart';

const PARTICIPANTS_SUB_COLLECTION = 'participants';
const NAME = 'name';
const PARTICIPANT_REF_ID = 'participantRefId';

class ParticipantRepository {
  final CollectionReference _repository = FirebaseFirestore.instance.collection(PARTICIPANTS_SUB_COLLECTION);

  Stream<QuerySnapshot> getParticipantsStream(DocumentReference gameRef) {
    return gameRef.collection(PARTICIPANTS_SUB_COLLECTION).snapshots();
  }

  Future<List<Participant>> findParticipants(DocumentReference gameRef) async {
    var participantsSnap = await gameRef.collection(PARTICIPANTS_SUB_COLLECTION).get();
    return participantsSnap.docs.map((snap) => Participant.fromSnapshot(snap)).toList();
  }

  Future<DocumentReference> addParticipant(DocumentReference gameRef, Participant participant) async {
    String generatedRefId = generateDocRefId();
    var participantJson = participant.toJson();
    participantJson[PARTICIPANT_REF_ID] = generatedRefId;
    DocumentReference doc = gameRef.collection(PARTICIPANTS_SUB_COLLECTION).doc(generatedRefId);
    await doc.set(participantJson);
    return doc;
  }

  void updateParticipant(Participant participant) async {
    participant.reference.update(participant.toJson());
  }

  Future<Participant> findParticipantByRef(DocumentReference participantRef) async {
    var participantSnap = await participantRef.get();
    return Participant.fromSnapshot(participantSnap);
  }

  Future<DocumentReference> findParticipantRefByName(DocumentReference gameRef, String name) async {
    var participant = await gameRef.collection(PARTICIPANTS_SUB_COLLECTION).where(NAME, isEqualTo: name).get();
    if (participant.docs.isEmpty) {
      return null;
    }
    return participant.docs.single.reference;
  }

  String generateDocRefId() {
    return _repository.doc().id;
  }
}
