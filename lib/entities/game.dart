import 'package:cloud_firestore/cloud_firestore.dart';

const PIN = 'pin';

class Game {
  int pin;
  DocumentReference reference;

  Game(this.pin);

  factory Game.fromSnapshot(DocumentSnapshot snapshot) {
    Game newGame = Game.fromJson(snapshot.data());
    newGame.reference = snapshot.reference;
    return newGame;
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(json[PIN] as int);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      PIN: pin,
    };
  }

  @override
  String toString() {
    return 'Game{$PIN: $pin}';
  }
}
