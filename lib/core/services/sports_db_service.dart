import 'dart:convert';
import 'package:http/http.dart' as http;

/// TheSportsDB API 서비스
/// API Key: 869004 (Premium)
/// v1: 일반 API, v2: 라이브스코어 전용
/// 문서: https://www.thesportsdb.com/api.php
class SportsDbService {
  static const String _baseUrlV1 = 'https://www.thesportsdb.com/api/v1/json';
  static const String _baseUrlV2 = 'https://www.thesportsdb.com/api/v2/json';
  static const String _apiKey = '869004';

  // 싱글톤 패턴
  static final SportsDbService _instance = SportsDbService._internal();
  factory SportsDbService() => _instance;
  SportsDbService._internal();

  /// v1 API 호출 헬퍼
  Future<Map<String, dynamic>?> _get(String endpoint) async {
    try {
      final url = '$_baseUrlV1/$_apiKey/$endpoint';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // 빈 응답 처리
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          return null;
        }
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('SportsDB v1 API Error: $e');
      return null;
    }
  }

  /// v2 API 호출 헬퍼 (라이브스코어용, 헤더 인증)
  Future<Map<String, dynamic>?> _getV2(String endpoint) async {
    try {
      final url = '$_baseUrlV2/$endpoint';
      final response = await http.get(
        Uri.parse(url),
        headers: {'X-API-KEY': _apiKey},
      );

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          return null;
        }
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('SportsDB v2 API Error: $e');
      return null;
    }
  }

  // ============ 팀 검색 ============

  /// 팀 이름으로 검색
  Future<List<SportsDbTeam>> searchTeams(String teamName) async {
    final data = await _get('searchteams.php?t=${Uri.encodeComponent(teamName)}');
    if (data == null || data['teams'] == null) return [];

    return (data['teams'] as List)
        .map((json) => SportsDbTeam.fromJson(json))
        .toList();
  }

  /// 리그별 팀 목록
  Future<List<SportsDbTeam>> getTeamsByLeague(String leagueName) async {
    final data = await _get('search_all_teams.php?l=${Uri.encodeComponent(leagueName)}');
    if (data == null || data['teams'] == null) return [];

    return (data['teams'] as List)
        .map((json) => SportsDbTeam.fromJson(json))
        .toList();
  }

  /// 팀 ID로 조회
  Future<SportsDbTeam?> getTeamById(String teamId) async {
    final data = await _get('lookupteam.php?id=$teamId');
    if (data == null || data['teams'] == null || (data['teams'] as List).isEmpty) {
      return null;
    }
    return SportsDbTeam.fromJson((data['teams'] as List).first);
  }

  // ============ 선수 검색 ============

  /// 선수 이름으로 검색
  Future<List<SportsDbPlayer>> searchPlayers(String playerName) async {
    final data = await _get('searchplayers.php?p=${Uri.encodeComponent(playerName)}');
    if (data == null || data['player'] == null) return [];

    return (data['player'] as List)
        .map((json) => SportsDbPlayer.fromJson(json))
        .toList();
  }

  /// 팀의 선수 목록
  Future<List<SportsDbPlayer>> getPlayersByTeam(String teamId) async {
    final data = await _get('lookup_all_players.php?id=$teamId');
    if (data == null || data['player'] == null) return [];

    return (data['player'] as List)
        .map((json) => SportsDbPlayer.fromJson(json))
        .toList();
  }

  /// 선수 ID로 조회
  Future<SportsDbPlayer?> getPlayerById(String playerId) async {
    final data = await _get('lookupplayer.php?id=$playerId');
    if (data == null || data['players'] == null || (data['players'] as List).isEmpty) {
      return null;
    }
    return SportsDbPlayer.fromJson((data['players'] as List).first);
  }

  /// 선수 계약 정보 조회 (Premium)
  Future<List<SportsDbContract>> getPlayerContracts(String playerId) async {
    final data = await _get('lookupcontracts.php?id=$playerId');
    if (data == null || data['contracts'] == null) return [];

    return (data['contracts'] as List)
        .map((json) => SportsDbContract.fromJson(json))
        .toList();
  }

  /// 선수 수상 경력 조회 (Premium)
  Future<List<SportsDbHonour>> getPlayerHonours(String playerId) async {
    final data = await _get('lookuphonours.php?id=$playerId');
    if (data == null || data['honours'] == null) return [];

    return (data['honours'] as List)
        .map((json) => SportsDbHonour.fromJson(json))
        .toList();
  }

  /// 선수 마일스톤 조회 (Premium)
  Future<List<SportsDbMilestone>> getPlayerMilestones(String playerId) async {
    final data = await _get('lookupmilestones.php?id=$playerId');
    if (data == null || data['milestones'] == null) return [];

    return (data['milestones'] as List)
        .map((json) => SportsDbMilestone.fromJson(json))
        .toList();
  }

  /// 선수 전 소속팀 조회 (Premium)
  Future<List<SportsDbFormerTeam>> getPlayerFormerTeams(String playerId) async {
    final data = await _get('lookupformerteams.php?id=$playerId');
    if (data == null || data['formerteams'] == null) return [];

    return (data['formerteams'] as List)
        .map((json) => SportsDbFormerTeam.fromJson(json))
        .toList();
  }

  // ============ 리그 ============

  /// 모든 리그 목록
  Future<List<SportsDbLeague>> getAllLeagues() async {
    final data = await _get('all_leagues.php');
    if (data == null || data['leagues'] == null) return [];

    return (data['leagues'] as List)
        .map((json) => SportsDbLeague.fromJson(json))
        .toList();
  }

  /// 국가와 스포츠로 리그 검색
  Future<List<SportsDbLeague>> searchLeagues(String country, String sport) async {
    final data = await _get(
        'search_all_leagues.php?c=${Uri.encodeComponent(country)}&s=${Uri.encodeComponent(sport)}');
    if (data == null || data['countries'] == null) return [];

    return (data['countries'] as List)
        .map((json) => SportsDbLeague.fromJson(json))
        .toList();
  }

  // ============ 경기 일정 ============

  /// 특정 날짜의 경기 (로컬 시간 기준)
  /// 한국 시간 기준 하루는 UTC 전날 15:00 ~ 당일 15:00 이므로
  /// 두 날짜의 경기를 가져와서 로컬 시간 기준으로 필터링
  Future<List<SportsDbEvent>> getEventsByDate(DateTime date, {String? sport, String? league}) async {
    // 로컬 날짜의 시작과 끝 (UTC로 변환)
    final localStart = DateTime(date.year, date.month, date.day);
    final localEnd = localStart.add(const Duration(days: 1));

    // UTC로 변환
    final utcStart = localStart.toUtc();
    final utcEnd = localEnd.toUtc();

    // UTC 기준으로 필요한 날짜들 (한국은 UTC+9이므로 전날과 당일 필요)
    final utcDates = <DateTime>{};
    utcDates.add(DateTime.utc(utcStart.year, utcStart.month, utcStart.day));
    utcDates.add(DateTime.utc(utcEnd.year, utcEnd.month, utcEnd.day));
    // 전날도 추가 (UTC 기준 전날 15:00~24:00 경기가 한국 당일이 될 수 있음)
    utcDates.add(DateTime.utc(utcStart.year, utcStart.month, utcStart.day).subtract(const Duration(days: 1)));

    final allEvents = <SportsDbEvent>[];

    // 각 UTC 날짜에 대해 API 호출
    for (final utcDate in utcDates) {
      final dateStr = '${utcDate.year}-${utcDate.month.toString().padLeft(2, '0')}-${utcDate.day.toString().padLeft(2, '0')}';
      String endpoint = 'eventsday.php?d=$dateStr';

      if (sport != null) {
        endpoint += '&s=${Uri.encodeComponent(sport)}';
      }
      if (league != null) {
        endpoint += '&l=${Uri.encodeComponent(league)}';
      }

      final data = await _get(endpoint);
      if (data != null && data['events'] != null) {
        final events = (data['events'] as List)
            .map((json) => SportsDbEvent.fromJson(json))
            .toList();
        allEvents.addAll(events);
      }
    }

    // 로컬 시간 기준으로 해당 날짜에 해당하는 경기만 필터링
    final filteredEvents = allEvents.where((event) {
      final eventDateTime = event.dateTime;
      if (eventDateTime == null) return false;

      return eventDateTime.year == date.year &&
          eventDateTime.month == date.month &&
          eventDateTime.day == date.day;
    }).toList();

    // 중복 제거 (같은 경기가 여러 번 나올 수 있음)
    final seen = <String>{};
    final uniqueEvents = filteredEvents.where((event) => seen.add(event.id)).toList();

    // 시간순 정렬
    uniqueEvents.sort((a, b) {
      final aTime = a.dateTime ?? DateTime.now();
      final bTime = b.dateTime ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    return uniqueEvents;
  }

  /// 리그의 다음 경기들
  Future<List<SportsDbEvent>> getNextLeagueEvents(String leagueId) async {
    final data = await _get('eventsnextleague.php?id=$leagueId');
    if (data == null || data['events'] == null) return [];

    return (data['events'] as List)
        .map((json) => SportsDbEvent.fromJson(json))
        .toList();
  }

  /// 리그의 지난 경기들
  Future<List<SportsDbEvent>> getPastLeagueEvents(String leagueId) async {
    final data = await _get('eventspastleague.php?id=$leagueId');
    if (data == null || data['events'] == null) return [];

    return (data['events'] as List)
        .map((json) => SportsDbEvent.fromJson(json))
        .toList();
  }

  /// 팀의 다음 경기들
  Future<List<SportsDbEvent>> getNextTeamEvents(String teamId) async {
    final data = await _get('eventsnext.php?id=$teamId');
    if (data == null || data['events'] == null) return [];

    return (data['events'] as List)
        .map((json) => SportsDbEvent.fromJson(json))
        .toList();
  }

  /// 팀의 지난 경기들
  Future<List<SportsDbEvent>> getPastTeamEvents(String teamId) async {
    final data = await _get('eventslast.php?id=$teamId');
    if (data == null) return [];

    // API 응답이 'results' 또는 'events' 키를 사용할 수 있음
    final events = data['results'] ?? data['events'];
    if (events == null) return [];

    return (events as List)
        .map((json) => SportsDbEvent.fromJson(json))
        .toList();
  }

  /// 이벤트 검색
  Future<List<SportsDbEvent>> searchEvents(String eventName, {String? season}) async {
    String endpoint = 'searchevents.php?e=${Uri.encodeComponent(eventName)}';
    if (season != null) {
      endpoint += '&s=${Uri.encodeComponent(season)}';
    }

    final data = await _get(endpoint);
    if (data == null || data['event'] == null) return [];

    return (data['event'] as List)
        .map((json) => SportsDbEvent.fromJson(json))
        .toList();
  }

  /// 이벤트 ID로 조회
  Future<SportsDbEvent?> getEventById(String eventId) async {
    final data = await _get('lookupevent.php?id=$eventId');
    if (data == null || data['events'] == null || (data['events'] as List).isEmpty) {
      return null;
    }
    return SportsDbEvent.fromJson((data['events'] as List).first);
  }

  // ============ 경기장 ============

  /// 경기장 검색
  Future<List<SportsDbVenue>> searchVenues(String venueName) async {
    final data = await _get('searchvenues.php?v=${Uri.encodeComponent(venueName)}');
    if (data == null || data['venues'] == null) return [];

    return (data['venues'] as List)
        .map((json) => SportsDbVenue.fromJson(json))
        .toList();
  }

  // ============ 경기 상세 정보 ============

  /// 경기 라인업 조회
  Future<SportsDbLineup?> getEventLineup(String eventId) async {
    final data = await _get('lookuplineup.php?id=$eventId');
    if (data == null || data['lineup'] == null) return null;

    return SportsDbLineup.fromJson(data['lineup'] as List);
  }

  /// 경기 통계 조회
  Future<SportsDbEventStats?> getEventStats(String eventId) async {
    final data = await _get('lookupeventstats.php?id=$eventId');
    if (data == null || data['eventstats'] == null) return null;

    final statsList = data['eventstats'] as List;
    if (statsList.isEmpty) return null;

    return SportsDbEventStats.fromStatsList(statsList);
  }

  /// 경기 타임라인 (골, 카드 등 이벤트)
  Future<List<SportsDbTimeline>> getEventTimeline(String eventId) async {
    final data = await _get('lookuptimeline.php?id=$eventId');
    if (data == null || data['timeline'] == null) return [];

    return (data['timeline'] as List)
        .map((json) => SportsDbTimeline.fromJson(json))
        .toList();
  }

  /// 경기 TV 중계 정보
  Future<List<SportsDbTv>> getEventTv(String eventId) async {
    final data = await _get('lookuptv.php?id=$eventId');
    if (data == null || data['tvevent'] == null) return [];

    return (data['tvevent'] as List)
        .map((json) => SportsDbTv.fromJson(json))
        .toList();
  }

  // ============ 리그 순위 ============

  /// 리그 순위표 조회
  Future<List<SportsDbStanding>> getLeagueStandings(String leagueId, {String? season}) async {
    String endpoint = 'lookuptable.php?l=$leagueId';
    if (season != null) {
      endpoint += '&s=${Uri.encodeComponent(season)}';
    }

    final data = await _get(endpoint);
    if (data == null || data['table'] == null) return [];

    return (data['table'] as List)
        .map((json) => SportsDbStanding.fromJson(json))
        .toList();
  }

  /// 리그 ID 조회 (리그 이름으로)
  Future<String?> getLeagueId(String leagueName) async {
    final data = await _get('search_all_leagues.php?l=${Uri.encodeComponent(leagueName)}');
    if (data == null || data['leagues'] == null || (data['leagues'] as List).isEmpty) {
      return null;
    }
    return (data['leagues'] as List).first['idLeague']?.toString();
  }

  // ============ 라이브스코어 (v2 API 전용) ============

  /// 축구 라이브스코어
  Future<List<SportsDbLiveEvent>> getSoccerLivescores() async {
    final data = await _getV2('livescore/soccer');
    if (data == null || data['livescore'] == null) return [];

    return (data['livescore'] as List)
        .map((json) => SportsDbLiveEvent.fromJson(json))
        .toList();
  }

  /// 리그별 라이브스코어
  Future<List<SportsDbLiveEvent>> getLivescoresByLeague(String leagueId) async {
    final data = await _getV2('livescore/$leagueId');
    if (data == null || data['livescore'] == null) return [];

    return (data['livescore'] as List)
        .map((json) => SportsDbLiveEvent.fromJson(json))
        .toList();
  }

  /// 전체 스포츠 라이브스코어
  Future<List<SportsDbLiveEvent>> getAllLivescores() async {
    final data = await _getV2('livescore/all');
    if (data == null || data['livescore'] == null) return [];

    return (data['livescore'] as List)
        .map((json) => SportsDbLiveEvent.fromJson(json))
        .toList();
  }

  // ============ 상대전적 (Head to Head) ============

  // 팀 이름 변형 맵 (정식 이름 -> 약어/과거 이름들)
  static const Map<String, List<String>> _teamNameVariants = {
    'tottenham hotspur': ['tottenham', 'spurs'],
    'tottenham': ['tottenham hotspur', 'spurs'],
    'manchester united': ['man united', 'man utd'],
    'manchester city': ['man city'],
    'newcastle united': ['newcastle'],
    'west ham united': ['west ham'],
    'wolverhampton wanderers': ['wolves', 'wolverhampton'],
    'wolves': ['wolverhampton wanderers', 'wolverhampton'],
    'nottingham forest': ["nott'm forest", 'nottingham'],
    'brighton & hove albion': ['brighton'],
    'leicester city': ['leicester'],
    'aston villa': ['villa'],
    'crystal palace': ['palace'],
    'athletic bilbao': ['athletic club', 'athletic'],
    'atletico madrid': ['atletico', 'atlético madrid'],
    'real madrid': ['real'],
    'fc barcelona': ['barcelona', 'barca'],
    'bayern munich': ['bayern', 'fc bayern'],
    'borussia dortmund': ['dortmund', 'bvb'],
    'rb leipzig': ['leipzig'],
    'paris saint-germain': ['psg', 'paris sg'],
    'olympique marseille': ['marseille', 'om'],
    'olympique lyonnais': ['lyon', 'ol'],
    'inter milan': ['inter', 'internazionale'],
    'ac milan': ['milan'],
    'juventus': ['juve'],
    'as roma': ['roma'],
    'napoli': ['ssc napoli'],
  };

  /// 팀 이름의 변형들을 가져옴
  List<String> _getTeamNameVariants(String teamName) {
    final lower = teamName.toLowerCase();
    final variants = <String>{lower};

    // 정확히 일치하는 변형 추가
    if (_teamNameVariants.containsKey(lower)) {
      variants.addAll(_teamNameVariants[lower]!);
    }

    // 역방향 검색 (변형에서 원본 찾기)
    for (final entry in _teamNameVariants.entries) {
      if (entry.value.any((v) => v.toLowerCase() == lower)) {
        variants.add(entry.key);
        variants.addAll(entry.value);
      }
    }

    // 첫 단어만 추출 (예: "Tottenham Hotspur" -> "Tottenham")
    final firstWord = lower.split(' ').first;
    if (firstWord.length >= 4) {
      variants.add(firstWord);
    }

    return variants.toList();
  }

  /// 두 팀 간의 상대전적 조회 (이름 검색 + 팀 ID 필터링)
  /// searchevents로 이름 검색 후, 팀 ID로 정확히 필터링
  Future<List<SportsDbEvent>> getHeadToHeadById(
    String homeTeamId,
    String awayTeamId,
    String homeTeamName,
    String awayTeamName,
  ) async {
    print('🔍 [H2H] 이름 검색 + ID 필터링 시작');
    print('🔍 [H2H] homeTeamId: $homeTeamId, awayTeamId: $awayTeamId');
    print('🔍 [H2H] homeTeamName: $homeTeamName, awayTeamName: $awayTeamName');

    final allEvents = <SportsDbEvent>[];
    final seenIds = <String>{};

    // 팀 이름 변형들 가져오기
    final homeVariants = _getTeamNameVariants(homeTeamName);
    final awayVariants = _getTeamNameVariants(awayTeamName);

    print('🔍 [H2H] 홈팀 변형: $homeVariants');
    print('🔍 [H2H] 원정팀 변형: $awayVariants');

    // 여러 조합으로 검색 (최대 6개 조합)
    int searchCount = 0;
    const maxSearches = 6;

    for (final home in homeVariants) {
      if (searchCount >= maxSearches) break;
      for (final away in awayVariants) {
        if (searchCount >= maxSearches) break;

        final homeEncoded = home.replaceAll(' ', '_');
        final awayEncoded = away.replaceAll(' ', '_');

        // 양방향 검색
        for (final query in ['${homeEncoded}_vs_$awayEncoded', '${awayEncoded}_vs_$homeEncoded']) {
          print('🔍 [H2H] 검색: $query');
          final data = await _get('searchevents.php?e=${Uri.encodeComponent(query)}');
          if (data != null && data['event'] != null) {
            for (final json in data['event'] as List) {
              final event = SportsDbEvent.fromJson(json);
              // 팀 ID로 정확히 필터링
              final isMatch = _isH2HMatch(event, homeTeamId, awayTeamId);
              if (isMatch && !seenIds.contains(event.id) && event.isFinished) {
                seenIds.add(event.id);
                allEvents.add(event);
                print('⚔️ [H2H] ${event.homeTeam} ${event.homeScore}-${event.awayScore} ${event.awayTeam} (${event.date}) - ${event.league}');
              }
            }
          }
        }
        searchCount++;
        if (allEvents.length >= 15) break;
      }
      if (allEvents.length >= 15) break;
    }

    print('✅ [H2H] 총 ${allEvents.length}경기 발견');

    // 날짜순 정렬 (최신순)
    allEvents.sort((a, b) {
      final aDate = a.dateTime ?? DateTime(1900);
      final bDate = b.dateTime ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });

    return allEvents;
  }

  /// H2H 매칭 확인 (팀 ID로 정확히)
  bool _isH2HMatch(SportsDbEvent event, String homeTeamId, String awayTeamId) {
    final matchHomeId = event.homeTeamId;
    final matchAwayId = event.awayTeamId;
    return (matchHomeId == homeTeamId && matchAwayId == awayTeamId) ||
           (matchHomeId == awayTeamId && matchAwayId == homeTeamId);
  }

  /// 두 팀 간의 상대전적 조회 (팀 이름 기반 - fallback)
  /// 팀 ID가 없을 때 사용, 이름 변형으로 검색
  Future<List<SportsDbEvent>> getHeadToHead(String homeTeam, String awayTeam) async {
    final allEvents = <SportsDbEvent>[];
    final seenIds = <String>{};

    // 팀 이름 변형들 가져오기
    final homeVariants = _getTeamNameVariants(homeTeam);
    final awayVariants = _getTeamNameVariants(awayTeam);

    // 모든 조합으로 검색 (최대 4개 조합만)
    int searchCount = 0;
    const maxSearches = 4;

    for (final home in homeVariants) {
      if (searchCount >= maxSearches) break;
      for (final away in awayVariants) {
        if (searchCount >= maxSearches) break;

        final homeEncoded = home.replaceAll(' ', '_');
        final awayEncoded = away.replaceAll(' ', '_');

        // 홈팀 vs 원정팀 검색
        final data1 = await _get('searchevents.php?e=${Uri.encodeComponent('${homeEncoded}_vs_$awayEncoded')}');
        if (data1 != null && data1['event'] != null) {
          for (final json in data1['event'] as List) {
            final event = SportsDbEvent.fromJson(json);
            if (!seenIds.contains(event.id) && event.isFinished) {
              seenIds.add(event.id);
              allEvents.add(event);
            }
          }
        }

        // 원정팀 vs 홈팀 검색 (역방향)
        final data2 = await _get('searchevents.php?e=${Uri.encodeComponent('${awayEncoded}_vs_$homeEncoded')}');
        if (data2 != null && data2['event'] != null) {
          for (final json in data2['event'] as List) {
            final event = SportsDbEvent.fromJson(json);
            if (!seenIds.contains(event.id) && event.isFinished) {
              seenIds.add(event.id);
              allEvents.add(event);
            }
          }
        }

        searchCount++;

        // 결과가 충분하면 조기 종료
        if (allEvents.length >= 10) break;
      }
      if (allEvents.length >= 10) break;
    }

    // 날짜순 정렬 (최신순)
    allEvents.sort((a, b) {
      final aDate = a.dateTime ?? DateTime(1900);
      final bDate = b.dateTime ?? DateTime(1900);
      return bDate.compareTo(aDate);
    });

    return allEvents;
  }
}

// ============ 모델 클래스들 ============

/// 팀 모델
class SportsDbTeam {
  final String id;
  final String name;
  final String? nameKr;
  final String? league;
  final String? country;
  final String? stadium;
  final String? stadiumCapacity;
  final String? badge;
  final String? jersey;
  final String? logo;
  final String? banner;
  final String? description;

  SportsDbTeam({
    required this.id,
    required this.name,
    this.nameKr,
    this.league,
    this.country,
    this.stadium,
    this.stadiumCapacity,
    this.badge,
    this.jersey,
    this.logo,
    this.banner,
    this.description,
  });

  factory SportsDbTeam.fromJson(Map<String, dynamic> json) {
    return SportsDbTeam(
      id: json['idTeam'] ?? '',
      name: json['strTeam'] ?? '',
      nameKr: json['strTeamAlternate'],
      league: json['strLeague'],
      country: json['strCountry'],
      stadium: json['strStadium'],
      stadiumCapacity: json['intStadiumCapacity']?.toString(),
      badge: json['strBadge'],
      jersey: json['strJersey'],
      logo: json['strLogo'],
      banner: json['strBanner'],
      description: json['strDescriptionEN'],
    );
  }
}

/// 선수 모델
class SportsDbPlayer {
  final String id;
  final String name;
  final String? nameKr;
  final String? team;
  final String? teamId;
  final String? teamBadge;
  final String? nationality;
  final String? position;
  final String? number;
  final String? dateBorn;
  final String? height;
  final String? weight;
  final String? photo;
  final String? thumb;
  final String? description;

  SportsDbPlayer({
    required this.id,
    required this.name,
    this.nameKr,
    this.team,
    this.teamId,
    this.teamBadge,
    this.nationality,
    this.position,
    this.number,
    this.dateBorn,
    this.height,
    this.weight,
    this.photo,
    this.thumb,
    this.description,
  });

  factory SportsDbPlayer.fromJson(Map<String, dynamic> json) {
    return SportsDbPlayer(
      id: json['idPlayer'] ?? '',
      name: json['strPlayer'] ?? '',
      nameKr: json['strPlayerAlternate'],
      team: json['strTeam'],
      teamId: json['idTeam'],
      teamBadge: json['strTeamBadge'],
      nationality: json['strNationality'],
      position: json['strPosition'],
      number: json['strNumber'],
      dateBorn: json['dateBorn'],
      height: json['strHeight'],
      weight: json['strWeight'],
      photo: json['strCutout'] ?? json['strThumb'],
      thumb: json['strThumb'],
      description: json['strDescriptionEN'],
    );
  }
}

/// 리그 모델
class SportsDbLeague {
  final String id;
  final String name;
  final String? nameKr;
  final String? sport;
  final String? country;
  final String? badge;
  final String? logo;
  final String? banner;
  final String? description;

  SportsDbLeague({
    required this.id,
    required this.name,
    this.nameKr,
    this.sport,
    this.country,
    this.badge,
    this.logo,
    this.banner,
    this.description,
  });

  factory SportsDbLeague.fromJson(Map<String, dynamic> json) {
    return SportsDbLeague(
      id: json['idLeague'] ?? '',
      name: json['strLeague'] ?? '',
      nameKr: json['strLeagueAlternate'],
      sport: json['strSport'],
      country: json['strCountry'],
      badge: json['strBadge'],
      logo: json['strLogo'],
      banner: json['strBanner'],
      description: json['strDescriptionEN'],
    );
  }
}

/// 경기(이벤트) 모델
class SportsDbEvent {
  final String id;
  final String name;
  final String? league;
  final String? leagueId;
  final String? season;
  final String? homeTeam;
  final String? homeTeamId;
  final String? homeTeamBadge;
  final String? awayTeam;
  final String? awayTeamId;
  final String? awayTeamBadge;
  final int? homeScore;
  final int? awayScore;
  final String? date;
  final String? time;
  final String? venue;
  final String? venueId;
  final String? thumb;
  final String? banner;
  final String? status;

  SportsDbEvent({
    required this.id,
    required this.name,
    this.league,
    this.leagueId,
    this.season,
    this.homeTeam,
    this.homeTeamId,
    this.homeTeamBadge,
    this.awayTeam,
    this.awayTeamId,
    this.awayTeamBadge,
    this.homeScore,
    this.awayScore,
    this.date,
    this.time,
    this.venue,
    this.venueId,
    this.thumb,
    this.banner,
    this.status,
  });

  factory SportsDbEvent.fromJson(Map<String, dynamic> json) {
    return SportsDbEvent(
      id: json['idEvent'] ?? '',
      name: json['strEvent'] ?? '',
      league: json['strLeague'],
      leagueId: json['idLeague'],
      season: json['strSeason'],
      homeTeam: json['strHomeTeam'],
      homeTeamId: json['idHomeTeam'],
      homeTeamBadge: json['strHomeTeamBadge'],
      awayTeam: json['strAwayTeam'],
      awayTeamId: json['idAwayTeam'],
      awayTeamBadge: json['strAwayTeamBadge'],
      homeScore: int.tryParse(json['intHomeScore']?.toString() ?? ''),
      awayScore: int.tryParse(json['intAwayScore']?.toString() ?? ''),
      date: json['dateEvent'],
      time: json['strTime'],
      venue: json['strVenue'],
      venueId: json['idVenue'],
      thumb: json['strThumb'],
      banner: json['strBanner'],
      status: json['strStatus'],
    );
  }

  /// 경기 완료 여부
  bool get isFinished => homeScore != null && awayScore != null;

  /// 스코어 표시 문자열
  String get scoreDisplay {
    if (isFinished) {
      return '$homeScore - $awayScore';
    }
    return 'vs';
  }

  /// 경기 날짜 DateTime (API는 UTC 시간 반환, 로컬 시간으로 변환)
  DateTime? get dateTime {
    if (date == null) return null;
    try {
      final parts = date!.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      int hour = 0;
      int minute = 0;

      if (time != null && time!.isNotEmpty) {
        final timeParts = time!.split(':');
        hour = int.parse(timeParts[0]);
        minute = int.parse(timeParts[1]);
      }

      // UTC로 파싱 후 로컬 시간으로 변환 (한국: UTC+9)
      // 시간 변환 시 날짜도 자동으로 변경됨
      final utcTime = DateTime.utc(year, month, day, hour, minute);
      return utcTime.toLocal();
    } catch (e) {
      return null;
    }
  }
}

/// 경기장 모델
class SportsDbVenue {
  final String id;
  final String name;
  final String? location;
  final String? country;
  final String? capacity;
  final String? description;
  final String? thumb;
  final String? map;

  SportsDbVenue({
    required this.id,
    required this.name,
    this.location,
    this.country,
    this.capacity,
    this.description,
    this.thumb,
    this.map,
  });

  factory SportsDbVenue.fromJson(Map<String, dynamic> json) {
    return SportsDbVenue(
      id: json['idVenue'] ?? '',
      name: json['strVenue'] ?? '',
      location: json['strLocation'],
      country: json['strCountry'],
      capacity: json['intCapacity']?.toString(),
      description: json['strDescriptionEN'],
      thumb: json['strThumb'],
      map: json['strMap'],
    );
  }
}

/// 라인업 선수 모델
class SportsDbLineupPlayer {
  final String id;
  final String name;
  final String? position;
  final String? number;
  final String? team;
  final String? teamId;
  final bool isSubstitute;
  final String? formation;  // 포지션 넘버 (4-3-3의 포지션 위치)

  SportsDbLineupPlayer({
    required this.id,
    required this.name,
    this.position,
    this.number,
    this.team,
    this.teamId,
    this.isSubstitute = false,
    this.formation,
  });

  factory SportsDbLineupPlayer.fromJson(Map<String, dynamic> json) {
    return SportsDbLineupPlayer(
      id: json['idPlayer']?.toString() ?? '',
      name: json['strPlayer'] ?? '',
      position: json['strPosition'],
      number: json['intSquadNumber']?.toString(),
      team: json['strTeam'],
      teamId: json['idTeam']?.toString(),
      isSubstitute: json['strSubstitute'] == 'Yes',
      formation: json['strPositionShort'],
    );
  }
}

/// 라인업 모델
class SportsDbLineup {
  final List<SportsDbLineupPlayer> homePlayers;
  final List<SportsDbLineupPlayer> awayPlayers;
  final List<SportsDbLineupPlayer> homeSubstitutes;
  final List<SportsDbLineupPlayer> awaySubstitutes;
  final String? homeFormation;
  final String? awayFormation;

  SportsDbLineup({
    required this.homePlayers,
    required this.awayPlayers,
    required this.homeSubstitutes,
    required this.awaySubstitutes,
    this.homeFormation,
    this.awayFormation,
  });

  factory SportsDbLineup.fromJson(List<dynamic> lineupList) {
    final homePlayers = <SportsDbLineupPlayer>[];
    final awayPlayers = <SportsDbLineupPlayer>[];
    final homeSubstitutes = <SportsDbLineupPlayer>[];
    final awaySubstitutes = <SportsDbLineupPlayer>[];
    String? homeFormation;
    String? awayFormation;

    for (final item in lineupList) {
      final player = SportsDbLineupPlayer.fromJson(item);

      // API에서 홈/원정 구분
      // strHome 필드: "Yes" = 홈팀, "No" = 원정팀
      final strHome = item['strHome']?.toString();
      final isHome = strHome?.toLowerCase() == 'yes';

      final isSub = player.isSubstitute;

      // 포메이션 추출 (첫 번째 선수에서)
      if (item['strFormation'] != null) {
        if (isHome && homeFormation == null) {
          homeFormation = item['strFormation'];
        } else if (!isHome && awayFormation == null) {
          awayFormation = item['strFormation'];
        }
      }

      if (isHome) {
        if (isSub) {
          homeSubstitutes.add(player);
        } else {
          homePlayers.add(player);
        }
      } else {
        if (isSub) {
          awaySubstitutes.add(player);
        } else {
          awayPlayers.add(player);
        }
      }
    }

    return SportsDbLineup(
      homePlayers: homePlayers,
      awayPlayers: awayPlayers,
      homeSubstitutes: homeSubstitutes,
      awaySubstitutes: awaySubstitutes,
      homeFormation: homeFormation,
      awayFormation: awayFormation,
    );
  }

  bool get isEmpty =>
      homePlayers.isEmpty &&
      awayPlayers.isEmpty &&
      homeSubstitutes.isEmpty &&
      awaySubstitutes.isEmpty;
}

/// 경기 통계 모델
class SportsDbEventStats {
  final int? homePossession;
  final int? awayPossession;
  final int? homeShots;
  final int? awayShots;
  final int? homeShotsOnTarget;
  final int? awayShotsOnTarget;
  final int? homeCorners;
  final int? awayCorners;
  final int? homeFouls;
  final int? awayFouls;
  final int? homeYellowCards;
  final int? awayYellowCards;
  final int? homeRedCards;
  final int? awayRedCards;
  final int? homeOffsides;
  final int? awayOffsides;

  SportsDbEventStats({
    this.homePossession,
    this.awayPossession,
    this.homeShots,
    this.awayShots,
    this.homeShotsOnTarget,
    this.awayShotsOnTarget,
    this.homeCorners,
    this.awayCorners,
    this.homeFouls,
    this.awayFouls,
    this.homeYellowCards,
    this.awayYellowCards,
    this.homeRedCards,
    this.awayRedCards,
    this.homeOffsides,
    this.awayOffsides,
  });

  factory SportsDbEventStats.fromJson(Map<String, dynamic> json) {
    return SportsDbEventStats(
      homePossession: int.tryParse(json['intHomePossession']?.toString() ?? ''),
      awayPossession: int.tryParse(json['intAwayPossession']?.toString() ?? ''),
      homeShots: int.tryParse(json['intHomeShots']?.toString() ?? ''),
      awayShots: int.tryParse(json['intAwayShots']?.toString() ?? ''),
      homeShotsOnTarget: int.tryParse(json['intHomeShotsOnTarget']?.toString() ?? ''),
      awayShotsOnTarget: int.tryParse(json['intAwayShotsOnTarget']?.toString() ?? ''),
      homeCorners: int.tryParse(json['intHomeCorners']?.toString() ?? ''),
      awayCorners: int.tryParse(json['intAwayCorners']?.toString() ?? ''),
      homeFouls: int.tryParse(json['intHomeFouls']?.toString() ?? ''),
      awayFouls: int.tryParse(json['intAwayFouls']?.toString() ?? ''),
      homeYellowCards: int.tryParse(json['intHomeYellowCards']?.toString() ?? ''),
      awayYellowCards: int.tryParse(json['intAwayYellowCards']?.toString() ?? ''),
      homeRedCards: int.tryParse(json['intHomeRedCards']?.toString() ?? ''),
      awayRedCards: int.tryParse(json['intAwayRedCards']?.toString() ?? ''),
      homeOffsides: int.tryParse(json['intHomeOffsides']?.toString() ?? ''),
      awayOffsides: int.tryParse(json['intAwayOffsides']?.toString() ?? ''),
    );
  }

  /// API가 배열로 각 통계를 개별 반환하는 경우 파싱
  factory SportsDbEventStats.fromStatsList(List<dynamic> statsList) {
    int? homePossession, awayPossession;
    int? homeShots, awayShots;
    int? homeShotsOnTarget, awayShotsOnTarget;
    int? homeCorners, awayCorners;
    int? homeFouls, awayFouls;
    int? homeYellowCards, awayYellowCards;
    int? homeRedCards, awayRedCards;
    int? homeOffsides, awayOffsides;

    for (final stat in statsList) {
      final statName = stat['strStat']?.toString().toLowerCase() ?? '';
      final homeVal = int.tryParse(stat['intHome']?.toString() ?? '');
      final awayVal = int.tryParse(stat['intAway']?.toString() ?? '');

      if (statName.contains('possession')) {
        homePossession = homeVal;
        awayPossession = awayVal;
      } else if (statName == 'total shots') {
        homeShots = homeVal;
        awayShots = awayVal;
      } else if (statName.contains('shots on goal') || statName.contains('shots on target')) {
        homeShotsOnTarget = homeVal;
        awayShotsOnTarget = awayVal;
      } else if (statName.contains('corner')) {
        homeCorners = homeVal;
        awayCorners = awayVal;
      } else if (statName == 'fouls') {
        homeFouls = homeVal;
        awayFouls = awayVal;
      } else if (statName.contains('yellow')) {
        homeYellowCards = homeVal;
        awayYellowCards = awayVal;
      } else if (statName.contains('red card')) {
        homeRedCards = homeVal;
        awayRedCards = awayVal;
      } else if (statName.contains('offside')) {
        homeOffsides = homeVal;
        awayOffsides = awayVal;
      }
    }

    return SportsDbEventStats(
      homePossession: homePossession,
      awayPossession: awayPossession,
      homeShots: homeShots,
      awayShots: awayShots,
      homeShotsOnTarget: homeShotsOnTarget,
      awayShotsOnTarget: awayShotsOnTarget,
      homeCorners: homeCorners,
      awayCorners: awayCorners,
      homeFouls: homeFouls,
      awayFouls: awayFouls,
      homeYellowCards: homeYellowCards,
      awayYellowCards: awayYellowCards,
      homeRedCards: homeRedCards,
      awayRedCards: awayRedCards,
      homeOffsides: homeOffsides,
      awayOffsides: awayOffsides,
    );
  }

  bool get isEmpty =>
      homePossession == null &&
      awayPossession == null &&
      homeShots == null &&
      awayShots == null;
}

/// 경기 타임라인 (골, 카드 등) 모델
class SportsDbTimeline {
  final String id;
  final String? type; // Goal, Card, subst
  final String? time; // 분 (예: "45", "90")
  final String? player;
  final String? assist; // 어시스트 선수
  final String? team;
  final String? teamId;
  final String? detail; // Yellow Card, Normal Goal 등
  final bool isHome;

  SportsDbTimeline({
    required this.id,
    this.type,
    this.time,
    this.player,
    this.assist,
    this.team,
    this.teamId,
    this.detail,
    this.isHome = true,
  });

  factory SportsDbTimeline.fromJson(Map<String, dynamic> json) {
    return SportsDbTimeline(
      id: json['idTimeline']?.toString() ?? '',
      type: json['strTimeline'],
      time: json['intTime']?.toString(),
      player: json['strPlayer'],
      assist: json['strAssist'],
      team: json['strTeam'],
      teamId: json['idTeam']?.toString(),
      detail: json['strTimelineDetail'],
      isHome: json['strHome']?.toString().toLowerCase() == 'yes',
    );
  }

  /// 시간 표시 (예: "45'")
  String get timeDisplay => time != null ? "$time'" : '';
}

/// TV 중계 정보 모델
class SportsDbTv {
  final String id;
  final String? channel;
  final String? country;
  final String? logo;
  final String? time;

  SportsDbTv({
    required this.id,
    this.channel,
    this.country,
    this.logo,
    this.time,
  });

  factory SportsDbTv.fromJson(Map<String, dynamic> json) {
    return SportsDbTv(
      id: json['idTvEvent']?.toString() ?? '',
      channel: json['strChannel'],
      country: json['strCountry'],
      logo: json['strLogo'],
      time: json['strTimeLocal'],
    );
  }
}

/// 선수 계약 정보 모델
class SportsDbContract {
  final String id;
  final String? playerId;
  final String? playerName;
  final String? teamId;
  final String? teamName;
  final String? teamBadge;
  final String? yearStart;
  final String? yearEnd;
  final String? wage;

  SportsDbContract({
    required this.id,
    this.playerId,
    this.playerName,
    this.teamId,
    this.teamName,
    this.teamBadge,
    this.yearStart,
    this.yearEnd,
    this.wage,
  });

  factory SportsDbContract.fromJson(Map<String, dynamic> json) {
    return SportsDbContract(
      id: json['id']?.toString() ?? '',
      playerId: json['idPlayer']?.toString(),
      playerName: json['strPlayer'],
      teamId: json['idTeam']?.toString(),
      teamName: json['strTeam'],
      teamBadge: json['strTeamBadge'],
      yearStart: json['strYearStart'],
      yearEnd: json['strYearEnd'],
      wage: json['strWage'],
    );
  }

  /// 현재 계약 여부
  bool get isCurrent {
    if (yearEnd == null) return true;
    final endYear = int.tryParse(yearEnd!);
    if (endYear == null) return false;
    return endYear >= DateTime.now().year;
  }

  /// 계약 기간 표시
  String get period {
    if (yearStart == null && yearEnd == null) return '-';
    if (yearEnd == null) return '$yearStart - 현재';
    return '$yearStart - $yearEnd';
  }
}

/// 선수 수상 경력 모델
class SportsDbHonour {
  final String id;
  final String? playerId;
  final String? teamId;
  final String? honour;
  final String? season;
  final String? teamName;

  SportsDbHonour({
    required this.id,
    this.playerId,
    this.teamId,
    this.honour,
    this.season,
    this.teamName,
  });

  factory SportsDbHonour.fromJson(Map<String, dynamic> json) {
    return SportsDbHonour(
      id: json['id']?.toString() ?? '',
      playerId: json['idPlayer']?.toString(),
      teamId: json['idTeam']?.toString(),
      honour: json['strHonour'],
      season: json['strSeason'],
      teamName: json['strTeam'],
    );
  }
}

/// 선수 마일스톤 모델
class SportsDbMilestone {
  final String id;
  final String? playerId;
  final String? milestone;
  final String? description;

  SportsDbMilestone({
    required this.id,
    this.playerId,
    this.milestone,
    this.description,
  });

  factory SportsDbMilestone.fromJson(Map<String, dynamic> json) {
    return SportsDbMilestone(
      id: json['id']?.toString() ?? '',
      playerId: json['idPlayer']?.toString(),
      milestone: json['strMilestone'],
      description: json['strMilestoneDescription'],
    );
  }
}

/// 선수 전 소속팀 모델
class SportsDbFormerTeam {
  final String id;
  final String? playerId;
  final String? teamId;
  final String? teamName;
  final String? teamBadge;
  final String? sport;
  final String? joined;
  final String? departed;

  SportsDbFormerTeam({
    required this.id,
    this.playerId,
    this.teamId,
    this.teamName,
    this.teamBadge,
    this.sport,
    this.joined,
    this.departed,
  });

  factory SportsDbFormerTeam.fromJson(Map<String, dynamic> json) {
    return SportsDbFormerTeam(
      id: json['id']?.toString() ?? '',
      playerId: json['idPlayer']?.toString(),
      teamId: json['idFormerTeam']?.toString(),
      teamName: json['strFormerTeam'],
      teamBadge: json['strBadge'],
      sport: json['strSport'],
      joined: json['strJoined'],
      departed: json['strDeparted'],
    );
  }

  /// 소속 기간 표시
  String get period {
    if (joined == null && departed == null) return '-';
    if (departed == null) return '$joined - ?';
    return '$joined - $departed';
  }
}

/// 리그 순위 모델
class SportsDbStanding {
  final String? teamId;
  final String? teamName;
  final String? teamBadge;
  final int rank;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;
  final String? form;
  final String? description;

  SportsDbStanding({
    this.teamId,
    this.teamName,
    this.teamBadge,
    required this.rank,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
    this.form,
    this.description,
  });

  factory SportsDbStanding.fromJson(Map<String, dynamic> json) {
    return SportsDbStanding(
      teamId: json['idTeam']?.toString(),
      teamName: json['strTeam'],
      teamBadge: json['strBadge'],
      rank: int.tryParse(json['intRank']?.toString() ?? '') ?? 0,
      played: int.tryParse(json['intPlayed']?.toString() ?? '') ?? 0,
      wins: int.tryParse(json['intWin']?.toString() ?? '') ?? 0,
      draws: int.tryParse(json['intDraw']?.toString() ?? '') ?? 0,
      losses: int.tryParse(json['intLoss']?.toString() ?? '') ?? 0,
      goalsFor: int.tryParse(json['intGoalsFor']?.toString() ?? '') ?? 0,
      goalsAgainst: int.tryParse(json['intGoalsAgainst']?.toString() ?? '') ?? 0,
      goalDifference: int.tryParse(json['intGoalDifference']?.toString() ?? '') ?? 0,
      points: int.tryParse(json['intPoints']?.toString() ?? '') ?? 0,
      form: json['strForm'],
      description: json['strDescription'],
    );
  }
}

/// 라이브스코어 이벤트 모델 (v2 API)
class SportsDbLiveEvent {
  final String id;
  final String name;
  final String? league;
  final String? leagueId;
  final String? homeTeam;
  final String? homeTeamId;
  final String? awayTeam;
  final String? awayTeamId;
  final String? homeBadge;
  final String? awayBadge;
  final int? homeScore;
  final int? awayScore;
  final String? status;       // 경기 상태 (예: "1H", "HT", "2H", "FT")
  final String? progress;     // 진행 시간 (예: "45'", "90+3'")
  final String? date;
  final String? time;

  SportsDbLiveEvent({
    required this.id,
    required this.name,
    this.league,
    this.leagueId,
    this.homeTeam,
    this.homeTeamId,
    this.awayTeam,
    this.awayTeamId,
    this.homeBadge,
    this.awayBadge,
    this.homeScore,
    this.awayScore,
    this.status,
    this.progress,
    this.date,
    this.time,
  });

  factory SportsDbLiveEvent.fromJson(Map<String, dynamic> json) {
    return SportsDbLiveEvent(
      id: json['idEvent']?.toString() ?? '',
      name: json['strEvent'] ?? '',
      league: json['strLeague'],
      leagueId: json['idLeague']?.toString(),
      homeTeam: json['strHomeTeam'],
      homeTeamId: json['idHomeTeam']?.toString(),
      awayTeam: json['strAwayTeam'],
      awayTeamId: json['idAwayTeam']?.toString(),
      homeBadge: json['strHomeTeamBadge'],
      awayBadge: json['strAwayTeamBadge'],
      homeScore: int.tryParse(json['intHomeScore']?.toString() ?? ''),
      awayScore: int.tryParse(json['intAwayScore']?.toString() ?? ''),
      status: json['strStatus'],
      progress: json['strProgress'],
      date: json['dateEvent'],
      time: json['strEventTime'],
    );
  }

  /// 스코어 표시
  String get scoreDisplay {
    if (homeScore != null && awayScore != null) {
      return '$homeScore - $awayScore';
    }
    return 'vs';
  }

  /// 경기 진행 중 여부 (status + 시간 기반)
  bool get isLive {
    final s = status?.toUpperCase() ?? '';

    // status가 명확히 진행 중인 경우
    if (s == '1H' || s == '2H' || s == 'HT' ||
        s == 'ET' || s == 'P' || s.contains('LIVE')) {
      return true;
    }

    // status가 비어있거나 불분명한 경우, 시간 기반으로 확인
    // 경기 시작 후 약 2시간 (120분) 이내이고, 종료 상태가 아니면 라이브로 간주
    if (!isFinished && dateTime != null) {
      final now = DateTime.now();
      final matchTime = dateTime!;
      final diff = now.difference(matchTime).inMinutes;

      // 경기 시작 시간 이후 ~ 120분 사이
      if (diff >= 0 && diff <= 120) {
        return true;
      }
    }

    return false;
  }

  /// 경기 종료 여부
  bool get isFinished {
    final s = status?.toUpperCase() ?? '';
    return s == 'FT' || s == 'AET' || s == 'AP' || s.contains('FINISHED');
  }

  /// 상태 표시 텍스트
  String get statusDisplay {
    if (progress != null && progress!.isNotEmpty) {
      return progress!;
    }
    return status ?? '';
  }

  /// 경기 날짜 DateTime (API는 UTC 시간 반환, 로컬 시간으로 변환)
  DateTime? get dateTime {
    if (date == null) return null;
    try {
      final parts = date!.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      int hour = 0;
      int minute = 0;

      if (time != null && time!.isNotEmpty) {
        final timeParts = time!.split(':');
        hour = int.parse(timeParts[0]);
        minute = int.parse(timeParts[1]);
      }

      // UTC로 파싱 후 로컬 시간으로 변환 (한국: UTC+9)
      final utcTime = DateTime.utc(year, month, day, hour, minute);
      return utcTime.toLocal();
    } catch (e) {
      return null;
    }
  }

  /// 로컬 시간 기준 경기 시간 표시
  String get localTimeDisplay {
    final dt = dateTime;
    if (dt == null) return time ?? '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
