import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/game.dart';

const GAMES_COLLECTION = 'games';

class GameRepository {
  final CollectionReference _repository = FirebaseFirestore.instance.collection(GAMES_COLLECTION);

  Stream<QuerySnapshot> getGamesStream() {
    return _repository.snapshots();
  }

  Future<DocumentReference> addGame(Game game) {
    return _repository.add(game.toJson());
  }

  Future<Game> findActiveGameByPin(int pin) async {
    var snapshot = await _repository.where(PIN, isEqualTo: pin).where(IS_ACTIVE, isEqualTo: true).get();
    return Game.fromSnapshot(snapshot.docs.single);
  }

  Future<DocumentReference> findActiveGameRefByPinNullable(int pin) async {
    var snapshot = await _repository.where(PIN, isEqualTo: pin).where(IS_ACTIVE, isEqualTo: true).get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return snapshot.docs.single.reference;
  }

  Future<Game> findActiveGameByRef(DocumentReference gameRef) async {
    var snapshot = await _repository.doc(gameRef.id).get();
    return Game.fromSnapshot(snapshot);
  }

  Future<Game> findActiveGameByPinNullable(int pin) async {
    var snapshot = await _repository.where(PIN, isEqualTo: pin).where(IS_ACTIVE, isEqualTo: true).get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    return Game.fromSnapshot(snapshot.docs.single);
  }
}
