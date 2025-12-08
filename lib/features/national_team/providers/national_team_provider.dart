import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/sports_db_service.dart';

// 대한민국 국가대표 팀 ID
const String koreaTeamId = '134517';

// 국가대표 관련 대회 정보
class NationalTeamCompetition {
  final String id;
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
  static const String worldCup = '4429';           // FIFA 월드컵 (본선)
  static const String worldCupQualifying = '4429_qualifying'; // 월드컵 예선 (가상 ID - 본선과 같은 리그에서 시즌으로 구분)
  static const String asianCup = '4866';           // AFC 아시안컵
  static const String friendlies = '4562';         // 친선경기

  // 월드컵 본선 시즌 (4년 단위)
  static const List<String> worldCupFinalSeasons = ['2022', '2026', '2030'];

  // 월드컵 예선인지 확인 (본선 시즌이 아닌 경우)
  static bool isQualifyingSeason(String? season) {
    if (season == null) return false;
    // 본선 시즌이 아니면 예선
    return !worldCupFinalSeasons.contains(season) &&
           !worldCupFinalSeasons.any((s) => season.contains(s));
  }

  static const List<NationalTeamCompetition> competitions = [
    NationalTeamCompetition(
      id: worldCup,
      name: 'FIFA 월드컵 본선',
      shortName: '월드컵',
      icon: '🏆',
    ),
    NationalTeamCompetition(
      id: worldCupQualifying,
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

/// 국가대표 팀 정보 Provider
final koreaTeamProvider = FutureProvider<SportsDbTeam?>((ref) async {
  final service = SportsDbService();
  return service.getTeamById(koreaTeamId);
});

/// 국가대표 다음 경기 Provider
final koreaNextMatchesProvider = FutureProvider<List<SportsDbEvent>>((ref) async {
  final service = SportsDbService();
  return service.getNextTeamEvents(koreaTeamId);
});

/// 국가대표 지난 경기 Provider
final koreaPastMatchesProvider = FutureProvider<List<SportsDbEvent>>((ref) async {
  final service = SportsDbService();
  return service.getPastTeamEvents(koreaTeamId);
});

/// 국가대표 전체 일정 Provider (다음 + 지난 경기)
final koreaAllMatchesProvider = FutureProvider<List<SportsDbEvent>>((ref) async {
  final nextMatches = await ref.watch(koreaNextMatchesProvider.future);
  final pastMatches = await ref.watch(koreaPastMatchesProvider.future);

  // 중복 제거 후 합치기
  final allEvents = <String, SportsDbEvent>{};
  for (final event in [...pastMatches, ...nextMatches]) {
    allEvents[event.id] = event;
  }

  // 날짜순 정렬 (최신순)
  final sorted = allEvents.values.toList()
    ..sort((a, b) {
      final aDate = a.dateTime ?? DateTime(1900);
      final bDate = b.dateTime ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });

  return sorted;
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
  // 2026 FIFA 월드컵 개막일 (미국, 캐나다, 멕시코 공동 개최)
  final worldCupStart = DateTime(2026, 6, 11);
  final now = DateTime.now();
  final daysRemaining = worldCupStart.difference(now).inDays;

  return WorldCupCountdown(
    worldCupStart: worldCupStart,
    daysRemaining: daysRemaining,
    tournamentName: '2026 FIFA 월드컵',
  );
});

/// 최근 5경기 폼 계산
class TeamForm {
  final List<String> results; // W, D, L
  final int wins;
  final int draws;
  final int losses;

  TeamForm({
    required this.results,
    required this.wins,
    required this.draws,
    required this.losses,
  });

  String get formString => results.join('-');
}

final koreaFormProvider = FutureProvider<TeamForm>((ref) async {
  final pastMatches = await ref.watch(koreaPastMatchesProvider.future);

  // 최근 5경기만
  final recent = pastMatches.take(5).toList();

  final results = <String>[];
  int wins = 0, draws = 0, losses = 0;

  for (final match in recent) {
    final homeScore = match.homeScore ?? 0;
    final awayScore = match.awayScore ?? 0;

    // 한국이 홈팀인지 원정팀인지 확인
    final isHome = match.homeTeam?.toLowerCase().contains('korea') ?? false;
    final koreaScore = isHome ? homeScore : awayScore;
    final opponentScore = isHome ? awayScore : homeScore;

    if (koreaScore > opponentScore) {
      results.add('W');
      wins++;
    } else if (koreaScore < opponentScore) {
      results.add('L');
      losses++;
    } else {
      results.add('D');
      draws++;
    }
  }

  return TeamForm(
    results: results,
    wins: wins,
    draws: draws,
    losses: losses,
  );
});

/// 국가대표 선수단 Provider (API에서 가져옴)
final koreaSquadProvider = FutureProvider<List<SportsDbPlayer>>((ref) async {
  final service = SportsDbService();
  return service.getPlayersByTeam(koreaTeamId);
});

/// 선택된 대회 필터 Provider (null = 전체)
final selectedCompetitionProvider = StateProvider<String?>((ref) => null);

/// 대한민국 경기인지 확인 (북한 제외)
bool _isSouthKoreaMatch(SportsDbEvent event) {
  final home = event.homeTeam?.toLowerCase() ?? '';
  final away = event.awayTeam?.toLowerCase() ?? '';

  // "south korea" 또는 "korea"가 포함되지만 "north korea"는 제외
  bool isHomeKorea = home == 'south korea' ||
                     (home.contains('korea') && !home.contains('north'));
  bool isAwayKorea = away == 'south korea' ||
                     (away.contains('korea') && !away.contains('north'));

  return isHomeKorea || isAwayKorea;
}

/// 대회별 일정 Provider
/// 팀 API는 최근 5경기만 반환하므로 대회별 시즌 데이터를 추가로 가져옴
final competitionMatchesProvider = FutureProvider.family<List<SportsDbEvent>, String>((ref, leagueId) async {
  final service = SportsDbService();
  final allEvents = <String, SportsDbEvent>{};

  // 월드컵 예선 특별 처리 (가상 ID)
  final isWorldCupQualifying = leagueId == NationalTeamLeagues.worldCupQualifying;
  final isWorldCupFinals = leagueId == NationalTeamLeagues.worldCup;
  final actualLeagueId = isWorldCupQualifying ? '4429' : leagueId;

  // 1. 한국 팀의 전체 경기에서 해당 대회 필터링
  final allKoreaMatches = await ref.watch(koreaAllMatchesProvider.future);
  for (final event in allKoreaMatches.where((e) => e.leagueId == actualLeagueId)) {
    // 월드컵 본선/예선 구분
    if (isWorldCupQualifying) {
      if (NationalTeamLeagues.isQualifyingSeason(event.season)) {
        allEvents[event.id] = event;
      }
    } else if (isWorldCupFinals) {
      if (!NationalTeamLeagues.isQualifyingSeason(event.season)) {
        allEvents[event.id] = event;
      }
    } else {
      allEvents[event.id] = event;
    }
  }

  // 2. 대회별로 시즌 데이터 추가 조회 (아시안컵, 월드컵 등)
  // 다양한 시즌 형식 지원 (2025, 2024-2025 등)
  final currentYear = DateTime.now().year;
  final seasons = [
    currentYear.toString(),
    (currentYear - 1).toString(),
    (currentYear - 2).toString(),
    '$currentYear-${currentYear + 1}',
    '${currentYear - 1}-$currentYear',
    '${currentYear - 2}-${currentYear - 1}',
  ];

  for (final season in seasons) {
    try {
      final seasonEvents = await service.getLeagueEventsBySeason(actualLeagueId, season);
      // 대한민국 경기만 필터링 (북한 제외)
      final koreaEvents = seasonEvents.where(_isSouthKoreaMatch);
      for (final event in koreaEvents) {
        // 월드컵 본선/예선 구분
        if (isWorldCupQualifying) {
          if (NationalTeamLeagues.isQualifyingSeason(event.season)) {
            allEvents[event.id] = event;
          }
        } else if (isWorldCupFinals) {
          if (!NationalTeamLeagues.isQualifyingSeason(event.season)) {
            allEvents[event.id] = event;
          }
        } else {
          allEvents[event.id] = event;
        }
      }
    } catch (_) {
      // 시즌 데이터가 없을 수 있음
    }
  }

  // 날짜순 정렬 (최신순)
  final sorted = allEvents.values.toList()
    ..sort((a, b) {
      final aDate = a.dateTime ?? DateTime(1900);
      final bDate = b.dateTime ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });

  return sorted;
});
