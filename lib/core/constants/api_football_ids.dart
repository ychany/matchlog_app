// API-Football ID 상수

class ApiFootballIds {
  ApiFootballIds._();

  /// 리그 이름으로 API-Football ID 가져오기
  static int? getLeagueId(String leagueName) {
    final name = leagueName.toLowerCase();

    // K리그
    if (name.contains('k league 1') || name.contains('k리그')) return LeagueIds.kLeague1;
    if (name.contains('k league 2')) return LeagueIds.kLeague2;

    // 유럽 5대 리그
    if (name.contains('premier league') || name.contains('epl')) return LeagueIds.premierLeague;
    if (name.contains('la liga') || name.contains('laliga')) return LeagueIds.laLiga;
    if (name.contains('bundesliga')) return LeagueIds.bundesliga;
    if (name.contains('serie a')) return LeagueIds.serieA;
    if (name.contains('ligue 1')) return LeagueIds.ligue1;

    // 유럽 대회
    if (name.contains('champions league') || name.contains('ucl')) return LeagueIds.championsLeague;
    if (name.contains('europa league') || name.contains('uel')) return LeagueIds.europaLeague;
    if (name.contains('conference league')) return LeagueIds.conferenceLeague;

    // 국제 대회
    if (name.contains('world cup') && !name.contains('qualif')) return LeagueIds.worldCup;
    if (name.contains('euro') && name.contains('championship')) return LeagueIds.euro;
    if (name.contains('asian cup')) return LeagueIds.asianCup;
    if (name.contains('friendl')) return LeagueIds.friendlies;

    return null;
  }
}

/// 리그 ID 상수
class LeagueIds {
  const LeagueIds();

  // 한국
  static const int kLeague1 = 292;
  static const int kLeague2 = 293;

  // 유럽 5대 리그
  static const int premierLeague = 39;
  static const int laLiga = 140;
  static const int bundesliga = 78;
  static const int serieA = 135;
  static const int ligue1 = 61;

  // 유럽 대회
  static const int championsLeague = 2;
  static const int europaLeague = 3;
  static const int conferenceLeague = 848;

  // 국제 대회
  static const int worldCup = 1;
  static const int euro = 4;
  static const int asianCup = 81;
  static const int friendlies = 10;
  static const int worldCupQualAsia = 30;

  // 현재 시즌 반환
  static int getCurrentSeason() {
    final now = DateTime.now();
    if (now.month >= 7) {
      return now.year;
    }
    return now.year;
  }

  /// 지원 리그 목록 (순위표 있는 리그)
  static const List<LeagueInfo> supportedLeagues = [
    LeagueInfo(id: kLeague1, name: 'K리그1', nameEn: 'K League 1', country: 'South Korea'),
    LeagueInfo(id: kLeague2, name: 'K리그2', nameEn: 'K League 2', country: 'South Korea'),
    LeagueInfo(id: premierLeague, name: '프리미어리그', nameEn: 'Premier League', country: 'England'),
    LeagueInfo(id: laLiga, name: '라리가', nameEn: 'La Liga', country: 'Spain'),
    LeagueInfo(id: bundesliga, name: '분데스리가', nameEn: 'Bundesliga', country: 'Germany'),
    LeagueInfo(id: serieA, name: '세리에 A', nameEn: 'Serie A', country: 'Italy'),
    LeagueInfo(id: ligue1, name: '리그 1', nameEn: 'Ligue 1', country: 'France'),
    LeagueInfo(id: championsLeague, name: 'UEFA 챔피언스리그', nameEn: 'Champions League', country: 'Europe'),
    LeagueInfo(id: europaLeague, name: 'UEFA 유로파리그', nameEn: 'Europa League', country: 'Europe'),
  ];

  /// ID로 리그 정보 가져오기
  static LeagueInfo? getLeagueInfo(int id) {
    try {
      return supportedLeagues.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// 팀 ID 상수 (사용 중인 것만)
class TeamIds {
  const TeamIds();

  // 국가대표
  static const int southKorea = 17;
}

/// 리그 정보 클래스
class LeagueInfo {
  final int id;
  final String name;
  final String nameEn;
  final String country;

  const LeagueInfo({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.country,
  });
}
