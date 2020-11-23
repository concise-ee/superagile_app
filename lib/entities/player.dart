import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/role.dart';

const NAME = 'name';
const UID = 'uid';
const LAST_ACTIVE = 'lastActive';
const ROLE = 'role';
const IS_PLAYING_ALONG = 'isPlayingAlong';

class Player {
  String name;
  String uid;
  String lastActive;
  Role role;
  bool isPlayingAlong;
  DocumentReference reference;

  Player(this.name, this.uid, this.lastActive, this.role, this.isPlayingAlong);

  factory Player.fromSnapshot(DocumentSnapshot snapshot) {
    var newPlayer = Player.fromJson(snapshot.data());
    newPlayer.reference = snapshot.reference;
    return newPlayer;
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(json[NAME], json[UID], json[LAST_ACTIVE], toRoleEnum(json[ROLE]), json[IS_PLAYING_ALONG]);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      NAME: name,
      UID: uid,
      LAST_ACTIVE: lastActive,
      ROLE: role.toExactString,
      IS_PLAYING_ALONG: isPlayingAlong
    };
  }

  @override
  String toString() {
    return 'Player{$NAME: $name, $UID: $uid, $LAST_ACTIVE: $lastActive, $ROLE: $role, $IS_PLAYING_ALONG: $isPlayingAlong}';
  }
}
