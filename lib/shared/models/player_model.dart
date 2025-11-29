import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Player extends Equatable {
  final String id;
  final String name;
  final String nameKr;
  final String? photoUrl;
  final String teamId;
  final String teamName;
  final String position;
  final int? number;
  final String? nationality;
  final DateTime? birthDate;

  const Player({
    required this.id,
    required this.name,
    required this.nameKr,
    this.photoUrl,
    required this.teamId,
    required this.teamName,
    required this.position,
    this.number,
    this.nationality,
    this.birthDate,
  });

  factory Player.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Player(
      id: doc.id,
      name: data['name'] as String,
      nameKr: data['nameKr'] as String? ?? data['name'] as String,
      photoUrl: data['photoUrl'] as String?,
      teamId: data['teamId'] as String,
      teamName: data['teamName'] as String,
      position: data['position'] as String,
      number: data['number'] as int?,
      nationality: data['nationality'] as String?,
      birthDate: data['birthDate'] != null
          ? (data['birthDate'] as Timestamp).toDate()
          : null,
    );
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKr: json['nameKr'] as String? ?? json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      teamId: json['teamId'] as String,
      teamName: json['teamName'] as String,
      position: json['position'] as String,
      number: json['number'] as int?,
      nationality: json['nationality'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameKr': nameKr,
      'photoUrl': photoUrl,
      'teamId': teamId,
      'teamName': teamName,
      'position': position,
      'number': number,
      'nationality': nationality,
      'birthDate': birthDate?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameKr,
        photoUrl,
        teamId,
        teamName,
        position,
        number,
        nationality,
        birthDate,
      ];

  // Example dummy data
  static List<Player> dummyPlayers() {
    return [
      Player(
        id: 'player_son',
        name: 'Son Heung-min',
        nameKr: 'e',
        photoUrl: 'https://example.com/son.png',
        teamId: 'team_tottenham',
        teamName: 'Tottenham Hotspur',
        position: 'Forward',
        number: 7,
        nationality: 'Korea',
        birthDate: DateTime(1992, 7, 8),
      ),
      Player(
        id: 'player_haaland',
        name: 'Erling Haaland',
        nameKr: ' @',
        photoUrl: 'https://example.com/haaland.png',
        teamId: 'team_mancity',
        teamName: 'Manchester City',
        position: 'Forward',
        number: 9,
        nationality: 'Norway',
        birthDate: DateTime(2000, 7, 21),
      ),
      Player(
        id: 'player_bellingham',
        name: 'Jude Bellingham',
        nameKr: ' ',
        photoUrl: 'https://example.com/bellingham.png',
        teamId: 'team_realmadrid',
        teamName: 'Real Madrid',
        position: 'Midfielder',
        number: 5,
        nationality: 'England',
        birthDate: DateTime(2003, 6, 29),
      ),
    ];
  }
}
