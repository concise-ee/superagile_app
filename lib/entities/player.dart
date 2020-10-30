import 'package:cloud_firestore/cloud_firestore.dart';

const NAME = 'name';
const UID = 'uid';
const LAST_ACTIVE = 'lastActive';

class Player {
  String name;
  String uid;
  String lastActive;
  DocumentReference reference;

  Player(this.name, this.uid, this.lastActive);

  factory Player.fromSnapshot(DocumentSnapshot snapshot) {
    Player newPlayer = Player.fromJson(snapshot.data());
    newPlayer.reference = snapshot.reference;
    return newPlayer;
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      json[NAME] as String,
      json[UID] as String,
      json[LAST_ACTIVE] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      NAME: name,
      UID: uid,
      LAST_ACTIVE: lastActive,
    };
  }

  @override
  String toString() {
    return 'Player{$NAME: $name, $UID: $uid, $LAST_ACTIVE: $lastActive}';
  }
}
