import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';

const PIN = 'pin';
const IS_ACTIVE = 'isActive';
const HOST_UID = 'hostUid';
const CREATED_AT = 'createdAt';
const GAME_STATE = 'gameState';
const AGREED_SCORES = 'agreedScores';
const LAST_UPDATE = 'lastUpdate';

class Game {
  int pin;
  bool isActive;
  String hostUid;
  DateTime createdAt = DateTime.now();
  DateTime lastUpdate = DateTime.now();
  String gameState;
  Map<String, int> agreedScores = {};
  DocumentReference reference;

  Game(this.pin, this.hostUid, this.isActive, this.gameState);

  factory Game.fromSnapshot(DocumentSnapshot snapshot) {
    var newGame = Game.fromJson(snapshot.data());
    newGame.reference = snapshot.reference;
    return newGame;
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    var game = Game(json[PIN], json[HOST_UID], json[IS_ACTIVE], json[GAME_STATE]);
    game.createdAt = DateTime.parse(json[CREATED_AT]);
    game.lastUpdate = DateTime.parse(json[LAST_UPDATE]);
    game.agreedScores =
        SplayTreeMap<String, int>.from(json[AGREED_SCORES], (a, b) => int.parse(a).compareTo(int.parse(b)));
    return game;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      PIN: pin,
      IS_ACTIVE: isActive,
      HOST_UID: hostUid,
      CREATED_AT: createdAt.toString(),
      LAST_UPDATE: lastUpdate.toString(),
      GAME_STATE: gameState,
      AGREED_SCORES: agreedScores
    };
  }

  @override
  String toString() {
    return '${runtimeType}{$PIN: $pin}';
  }
}
