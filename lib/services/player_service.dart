import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/repositories/player_repository.dart';

const ACTIVITY_INTERVAL = 15;

class PlayerService {
  final PlayerRepository _playerRepository = PlayerRepository();

  List<Player> findActivePlayers(List<QueryDocumentSnapshot> snaps) {
    return snaps
        .map((playerSnap) => Player.fromSnapshot(playerSnap))
        .where((player) => player.isPlayingAlong == true)
        .where((player) =>
            DateTime.parse(player.lastActive).isAfter(DateTime.now().subtract(Duration(seconds: ACTIVITY_INTERVAL))))
        .toList();
  }

  Future<bool> checkIfPlayerIsActive(DocumentReference playerRef) async {
    var player = await _playerRepository.findGamePlayerByRef(playerRef);
    return DateTime.parse(player.lastActive).isAfter(DateTime.now().subtract(Duration(seconds: ACTIVITY_INTERVAL)));
  }

  void sendLastActive(DocumentReference playerRef) async {
    Player player = await _playerRepository.findGamePlayerByRef(playerRef);
    player.lastActive = DateTime.now().toString();
    _playerRepository.updateGamePlayer(player);
  }

  Future<DocumentReference> addGamePlayer(DocumentReference gameRef, Player player) {
    return _playerRepository.addGamePlayer(gameRef, player);
  }

  Future<List<Player>> findGamePlayers(DocumentReference gameRef) {
    return _playerRepository.findGamePlayers(gameRef);
  }

  Future<List<Player>> findActiveGamePlayers(DocumentReference gameRef) async {
    List<Player> players = await _playerRepository.findGamePlayers(gameRef);
    players.sort((a, b) => (a.name).compareTo(b.name));
    return players
        .where((player) =>
            DateTime.parse(player.lastActive).isAfter(DateTime.now().subtract(Duration(seconds: ACTIVITY_INTERVAL))))
        .toList();
  }

  Stream<QuerySnapshot> getGamePlayersStream(DocumentReference gameRef) {
    return _playerRepository.getGamePlayersStream(gameRef);
  }

  Future<Player> findGamePlayerByRef(DocumentReference playerRef) async {
    return await _playerRepository.findGamePlayerByRef(playerRef);
  }

  Future<DocumentReference> findPlayerRefByName(DocumentReference gameRef, String name) {
    return _playerRepository.findPlayerRefByName(gameRef, name);
  }
}
