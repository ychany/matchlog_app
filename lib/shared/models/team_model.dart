import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Team extends Equatable {
  final String id;
  final String name;
  final String nameKr;
  final String shortName;
  final String? logoUrl;
  final String league;
  final String? stadiumName;
  final String? country;

  const Team({
    required this.id,
    required this.name,
    required this.nameKr,
    required this.shortName,
    this.logoUrl,
    required this.league,
    this.stadiumName,
    this.country,
  });

  factory Team.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Team(
      id: doc.id,
      name: data['name'] as String,
      nameKr: data['nameKr'] as String? ?? data['name'] as String,
      shortName: data['shortName'] as String,
      logoUrl: data['logoUrl'] as String?,
      league: data['league'] as String,
      stadiumName: data['stadiumName'] as String?,
      country: data['country'] as String?,
    );
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] as String,
      name: json['name'] as String,
      nameKr: json['nameKr'] as String? ?? json['name'] as String,
      shortName: json['shortName'] as String,
      logoUrl: json['logoUrl'] as String?,
      league: json['league'] as String,
      stadiumName: json['stadiumName'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameKr': nameKr,
      'shortName': shortName,
      'logoUrl': logoUrl,
      'league': league,
      'stadiumName': stadiumName,
      'country': country,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        nameKr,
        shortName,
        logoUrl,
        league,
        stadiumName,
        country,
      ];

  // Example dummy data
  static List<Team> dummyTeams() {
    return [
      const Team(
        id: 'team_mancity',
        name: 'Manchester City',
        nameKr: '贤0 ',
        shortName: 'MCI',
        logoUrl: 'https://example.com/mancity.png',
        league: 'EPL',
        stadiumName: 'Etihad Stadium',
        country: 'England',
      ),
      const Team(
        id: 'team_tottenham',
        name: 'Tottenham Hotspur',
        nameKr: ' K|',
        shortName: 'TOT',
        logoUrl: 'https://example.com/tottenham.png',
        league: 'EPL',
        stadiumName: 'Tottenham Hotspur Stadium',
        country: 'England',
      ),
      const Team(
        id: 'team_realmadrid',
        name: 'Real Madrid',
        nameKr: 'L ܬ',
        shortName: 'RMA',
        logoUrl: 'https://example.com/realmadrid.png',
        league: 'La Liga',
        stadiumName: 'Santiago Bernabu',
        country: 'Spain',
      ),
      const Team(
        id: 'team_fcseoul',
        name: 'FC Seoul',
        nameKr: 'FC ',
        shortName: 'SEO',
        logoUrl: 'https://example.com/fcseoul.png',
        league: 'K-League',
        stadiumName: '0',
        country: 'Korea',
      ),
    ];
  }
}
