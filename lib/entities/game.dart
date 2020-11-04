import 'package:cloud_firestore/cloud_firestore.dart';

const PIN = 'pin';
const IS_ACTIVE = 'isActive';
const HOST_UID = 'hostUid';

class Game {
  int pin;
  bool isActive;
  String hostUid;
  DocumentReference reference;

  Game(this.pin, this.hostUid, this.isActive);

  factory Game.fromSnapshot(DocumentSnapshot snapshot) {
    var newGame = Game.fromJson(snapshot.data());
    newGame.reference = snapshot.reference;
    return newGame;
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(json[PIN] as int, json[HOST_UID] as String, json[IS_ACTIVE] as bool);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      PIN: pin,
      IS_ACTIVE: isActive,
      HOST_UID: hostUid,
    };
  }

  @override
  String toString() {
    return 'Game{$PIN: $pin}';
  }
}
