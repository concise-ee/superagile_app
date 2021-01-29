import 'package:cloud_firestore/cloud_firestore.dart';

const PARTICIPANTS_SUB_COLLECTION = 'participants';

class ParticipantRepository {
  final CollectionReference _repository = FirebaseFirestore.instance.collection(PARTICIPANTS_SUB_COLLECTION);

  String generateDocRefId() {
    return _repository.doc().id;
  }
}
