import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_football_service.dart';
import '../../../core/constants/api_football_ids.dart';

// 국가대표 관련 대회 정보
class NationalTeamCompetition {
  final int id;
  final String name;
  final String shortName;
  final String icon;

  const NationalTeamCompetition({
    required this.id,
    required this.name,
    required this.shortName,
    required this.icon,
  });
}

class NationalTeamLeagues {
  static const int worldCup = LeagueIds.worldCup;
  static const int worldCupQualAsia = LeagueIds.worldCupQualAsia;
  static const int asianCup = LeagueIds.asianCup;
  static const int friendlies = LeagueIds.friendlies;

  static const List<NationalTeamCompetition> competitions = [
    NationalTeamCompetition(
      id: worldCup,
      name: 'FIFA 월드컵 본선',
      shortName: '월드컵',
      icon: '🏆',
    ),
    NationalTeamCompetition(
      id: worldCupQualAsia,
      name: '월드컵 예선 (AFC)',
      shortName: 'WC예선',
      icon: '⚽',
    ),
    NationalTeamCompetition(
      id: asianCup,
      name: 'AFC 아시안컵',
      shortName: '아시안컵',
      icon: '🏅',
    ),
    NationalTeamCompetition(
      id: friendlies,
      name: '친선경기',
      shortName: 'A매치',
      icon: '🤝',
    ),
  ];
}

/// API-Football 서비스 Provider
final apiFootballServiceProvider = Provider<ApiFootballService>((ref) {
  return ApiFootballService();
});

/// 2026 월드컵 카운트다운 정보
class WorldCupCountdown {
  final DateTime worldCupStart;
  final int daysRemaining;
  final String tournamentName;

  WorldCupCountdown({
    required this.worldCupStart,
    required this.daysRemaining,
    required this.tournamentName,
  });
}

/// 2026 월드컵 카운트다운 Provider
final worldCupCountdownProvider = Provider<WorldCupCountdown>((ref) {
  final worldCupStart = DateTime(2026, 6, 11);
  final now = DateTime.now();
  final daysRemaining = worldCupStart.difference(now).inDays;

  return WorldCupCountdown(
    worldCupStart: worldCupStart,
    daysRemaining: daysRemaining,
    tournamentName: '2026 FIFA 월드컵',
  );
});
