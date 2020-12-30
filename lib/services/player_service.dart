import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:superagile_app/entities/player.dart';
import 'package:superagile_app/entities/role.dart';
import 'package:superagile_app/repositories/player_repository.dart';

class PlayerService {
  final PlayerRepository _playerRepository = PlayerRepository();

  List<Player> findActivePlayers(List<QueryDocumentSnapshot> snaps) {
    return snaps
        .map((playerSnap) => Player.fromSnapshot(playerSnap))
        .where((player) => player.isPlayingAlong == true)
        .where((player) => DateTime.parse(player.lastActive).isAfter(DateTime.now().subtract(Duration(seconds: 11))))
        .toList();
  }

  void sendLastActive(DocumentReference playerRef) async {
    Player player = await _playerRepository.findGamePlayerByRef(playerRef);
    player.lastActive = DateTime.now().toString();
    _playerRepository.updateGamePlayer(player);
  }

  Future<DocumentReference> addGamePlayer(DocumentReference reference, Player player) {
    return _playerRepository.addGamePlayer(reference, player);
  }

  Future<List<Player>> findGamePlayers(DocumentReference gameRef) {
    return _playerRepository.findGamePlayers(gameRef);
  }

  Future<bool> isPlayerHosting(DocumentReference playerRef) async {
    Player player = await _playerRepository.findGamePlayerByRef(playerRef);
    return player.role == Role.HOST;
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
