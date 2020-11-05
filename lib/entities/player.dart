import 'package:cloud_firestore/cloud_firestore.dart';

const NAME = 'name';
const UID = 'uid';
const LAST_ACTIVE = 'lastActive';
const ROLE = 'role';
const IS_PLAYING_ALONG = 'isPlayingAlong';

class Player {
  String name;
  String uid;
  String lastActive;
  String role;
  bool isPlayingAlong;
  DocumentReference reference;

  Player(this.name, this.uid, this.lastActive, this.role, this.isPlayingAlong);

  factory Player.fromSnapshot(DocumentSnapshot snapshot) {
    var newPlayer = Player.fromJson(snapshot.data());
    newPlayer.reference = snapshot.reference;
    return newPlayer;
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(json[NAME] as String, json[UID] as String, json[LAST_ACTIVE] as String, json[ROLE] as String,
        json[IS_PLAYING_ALONG] as bool);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      NAME: name,
      UID: uid,
      LAST_ACTIVE: lastActive,
      ROLE: role,
      IS_PLAYING_ALONG: isPlayingAlong
    };
  }

  @override
  String toString() {
    return 'Player{$NAME: $name, $UID: $uid, $LAST_ACTIVE: $lastActive, $ROLE: $role, $IS_PLAYING_ALONG: $isPlayingAlong}';
  }
}
