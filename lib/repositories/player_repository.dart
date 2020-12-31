import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/player.dart';

const PLAYERS_SUB_COLLECTION = 'players';
const NAME = 'name';
const PLAYER_REF_ID = 'playerRefId';

class PlayerRepository {
  final CollectionReference _repository = FirebaseFirestore.instance.collection(PLAYERS_SUB_COLLECTION);

  Stream<QuerySnapshot> getGamePlayersStream(DocumentReference gameRef) {
    return gameRef.collection(PLAYERS_SUB_COLLECTION).snapshots();
  }

  Future<List<Player>> findGamePlayers(DocumentReference gameRef) async {
    var playersSnap = await gameRef.collection(PLAYERS_SUB_COLLECTION).get();
    return playersSnap.docs.map((snap) => Player.fromSnapshot(snap)).toList();
  }

  Future<DocumentReference> addGamePlayer(DocumentReference gameRef, Player player) async {
    String generatedRefId = generateDocRefId();
    var playerJson = player.toJson();
    playerJson[PLAYER_REF_ID] = generatedRefId;
    DocumentReference doc = gameRef.collection(PLAYERS_SUB_COLLECTION).doc(generatedRefId);
    await doc.set(playerJson);
    return doc;
  }

  void updateGamePlayer(Player player) async {
    player.reference.update(player.toJson());
  }

  Future<Player> findGamePlayerByRef(DocumentReference playerRef) async {
    var playerSnap = await playerRef.get();
    return Player.fromSnapshot(playerSnap);
  }

  Future<DocumentReference> findPlayerRefByName(DocumentReference gameRef, String name) async {
    var player = await gameRef.collection(PLAYERS_SUB_COLLECTION).where(NAME, isEqualTo: name).get();
    if (player.docs.isEmpty) {
      return null;
    }
    return player.docs.single.reference;
  }

  String generateDocRefId() {
    return _repository.doc().id;
  }
}
