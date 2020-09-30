import 'package:cloud_firestore/cloud_firestore.dart';

import 'Player.dart';

class Game {
  int pin;
  List<Player> players;
  DocumentReference reference;

  Game(this.pin, this.players);

  factory Game.fromSnapshot(DocumentSnapshot snapshot) {
    Game newGame = Game.fromJson(snapshot.data);
    newGame.reference = snapshot.reference;
    return newGame;
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    var playersJson = json['players'] as List;
    List<Player> players = [];

    for (final el in playersJson) {
      players.add(Player.fromJson(el));
    }
    return Game(json["pin"] as int, players);
  }

  Map<String, dynamic> toJson() {
    var playerList = [];
    for (final player in players) {
      var playersMap = new Map();
      playersMap["name"] = player.name;
      playersMap["lastActive"] = player.lastActive;
      playerList.add(playersMap);
    }
    return <String, dynamic>{
      'pin': pin,
      'players': playerList,
    };
  }

  @override
  String toString() => "Game<$pin, $players>";
}
