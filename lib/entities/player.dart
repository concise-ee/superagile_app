class Player {
  String name;
  String lastActive;

  Player(this.name, this.lastActive);

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      json['name'] as String,
      json['lastActive'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'lastActive': lastActive,
    };
  }

  @override
  String toString() {
    return 'Player{name: $name, lastActive: $lastActive}';
  }
}
