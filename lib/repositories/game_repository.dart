import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';

class GameRepository {
  final CollectionReference _repository =
      Firestore.instance.collection('games');

  Stream<QuerySnapshot> getStream() {
    return _repository.snapshots();
  }

  Future<DocumentReference> addGame(Game game) {
    return _repository.add(game.toJson());
  }

  Future<Game> findGameByRef(DocumentReference ref) async {
    DocumentSnapshot snapshot =
        await _repository.document(ref.documentID).get();
    return Game.fromSnapshot(snapshot);
  }

  Future<Game> findGameByPin(int pin) async {
    QuerySnapshot result =
        await _repository.where('pin', isEqualTo: pin).getDocuments();
    if (result.documents.isEmpty || result.documents.length > 1) {
      throw ("findGameByPin documents count is not 1");
    }
    return Game.fromSnapshot(result.documents[0]);
  }

  updateGame(Game game) async {
    await _repository
        .document(game.reference.documentID)
        .updateData(game.toJson());
  }
}
