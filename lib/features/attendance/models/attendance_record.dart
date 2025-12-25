import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import '../../../l10n/app_localizations.dart';

enum MatchResult { win, draw, loss, unknown }

/// 경기 감정/분위기
enum MatchMood {
  excited,    // 신남
  happy,      // 기쁨
  satisfied,  // 만족
  neutral,    // 보통
  disappointed, // 아쉬움
  sad,        // 슬픔
  angry,      // 분노
}

extension MatchMoodExtension on MatchMood {
  String get emoji {
    switch (this) {
      case MatchMood.excited: return '🔥';
      case MatchMood.happy: return '😄';
      case MatchMood.satisfied: return '😊';
      case MatchMood.neutral: return '😐';
      case MatchMood.disappointed: return '😔';
      case MatchMood.sad: return '😢';
      case MatchMood.angry: return '😤';
    }
  }

  String get label {
    switch (this) {
      case MatchMood.excited: return '신남';
      case MatchMood.happy: return '기쁨';
      case MatchMood.satisfied: return '만족';
      case MatchMood.neutral: return '보통';
      case MatchMood.disappointed: return '아쉬움';
      case MatchMood.sad: return '슬픔';
      case MatchMood.angry: return '분노';
    }
  }

  String getLocalizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case MatchMood.excited: return l10n.moodExcited;
      case MatchMood.happy: return l10n.moodHappy;
      case MatchMood.satisfied: return l10n.moodSatisfied;
      case MatchMood.neutral: return l10n.moodNeutral;
      case MatchMood.disappointed: return l10n.moodDisappointed;
      case MatchMood.sad: return l10n.moodSad;
      case MatchMood.angry: return l10n.moodAngry;
    }
  }
}

class AttendanceRecord extends Equatable {
  final String id;
  final String userId;
  final DateTime date;
  final String league;
  final String homeTeamId;
  final String homeTeamName;
  final String? homeTeamLogo;
  final String awayTeamId;
  final String awayTeamName;
  final String? awayTeamLogo;
  final String stadium;
  final String? seatInfo;
  final int? homeScore;
  final int? awayScore;
  final String? memo;
  final List<String> photos;
  final double? latitude;
  final double? longitude;
  final String? matchId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 일기 기능 확장 필드
  final String? diaryTitle;       // 일기 제목
  final String? diaryContent;     // 일기 본문 (긴 글)
  final double? rating;           // 경기 평점 (1~5)
  final MatchMood? mood;          // 감정/분위기
  final String? mvpPlayerId;      // 오늘의 MVP
  final String? mvpPlayerName;    // MVP 이름
  final List<String> tags;        // 해시태그
  final String? weather;          // 날씨
  final String? companion;        // 함께 간 사람
  final int? ticketPrice;         // 티켓 가격
  final String? foodReview;       // 경기장 음식 후기
  final bool isFavorite;          // 즐겨찾기
  final String? supportedTeamId;  // 내가 응원한 팀 ID (승/무/패 계산용)

  const AttendanceRecord({
    required this.id,
    required this.userId,
    required this.date,
    required this.league,
    required this.homeTeamId,
    required this.homeTeamName,
    this.homeTeamLogo,
    required this.awayTeamId,
    required this.awayTeamName,
    this.awayTeamLogo,
    required this.stadium,
    this.seatInfo,
    this.homeScore,
    this.awayScore,
    this.memo,
    this.photos = const [],
    this.latitude,
    this.longitude,
    this.matchId,
    required this.createdAt,
    required this.updatedAt,
    // 일기 확장 필드
    this.diaryTitle,
    this.diaryContent,
    this.rating,
    this.mood,
    this.mvpPlayerId,
    this.mvpPlayerName,
    this.tags = const [],
    this.weather,
    this.companion,
    this.ticketPrice,
    this.foodReview,
    this.isFavorite = false,
    this.supportedTeamId,
  });

  MatchResult getResultForTeam(String teamId) {
    if (homeScore == null || awayScore == null) return MatchResult.unknown;

    if (homeScore == awayScore) return MatchResult.draw;

    if (teamId == homeTeamId) {
      return homeScore! > awayScore! ? MatchResult.win : MatchResult.loss;
    } else if (teamId == awayTeamId) {
      return awayScore! > homeScore! ? MatchResult.win : MatchResult.loss;
    }
    return MatchResult.unknown;
  }

  String get scoreDisplay {
    if (homeScore == null || awayScore == null) return '-';
    return '$homeScore : $awayScore';
  }

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Timestamp 안전하게 파싱하는 헬퍼 함수
    DateTime parseTimestamp(dynamic value, {DateTime? fallback}) {
      if (value == null) return fallback ?? DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return fallback ?? DateTime.now();
    }

    return AttendanceRecord(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      date: parseTimestamp(data['date']),
      league: data['league'] as String? ?? '',
      homeTeamId: data['homeTeamId'] as String? ?? '',
      homeTeamName: data['homeTeamName'] as String? ?? '',
      homeTeamLogo: data['homeTeamLogo'] as String?,
      awayTeamId: data['awayTeamId'] as String? ?? '',
      awayTeamName: data['awayTeamName'] as String? ?? '',
      awayTeamLogo: data['awayTeamLogo'] as String?,
      stadium: data['stadium'] as String? ?? '',
      seatInfo: data['seatInfo'] as String?,
      homeScore: data['homeScore'] as int?,
      awayScore: data['awayScore'] as int?,
      memo: data['memo'] as String?,
      photos: List<String>.from(data['photos'] ?? []),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      matchId: data['matchId'] as String?,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
      // 일기 확장 필드
      diaryTitle: data['diaryTitle'] as String?,
      diaryContent: data['diaryContent'] as String?,
      rating: (data['rating'] as num?)?.toDouble(),
      mood: data['mood'] != null
          ? MatchMood.values.firstWhere(
              (e) => e.name == data['mood'],
              orElse: () => MatchMood.neutral,
            )
          : null,
      mvpPlayerId: data['mvpPlayerId'] as String?,
      mvpPlayerName: data['mvpPlayerName'] as String?,
      tags: List<String>.from(data['tags'] ?? []),
      weather: data['weather'] as String?,
      companion: data['companion'] as String?,
      ticketPrice: data['ticketPrice'] as int?,
      foodReview: data['foodReview'] as String?,
      isFavorite: data['isFavorite'] as bool? ?? false,
      supportedTeamId: data['supportedTeamId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'league': league,
      'homeTeamId': homeTeamId,
      'homeTeamName': homeTeamName,
      'homeTeamLogo': homeTeamLogo,
      'awayTeamId': awayTeamId,
      'awayTeamName': awayTeamName,
      'awayTeamLogo': awayTeamLogo,
      'stadium': stadium,
      'seatInfo': seatInfo,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'memo': memo,
      'photos': photos,
      'latitude': latitude,
      'longitude': longitude,
      'matchId': matchId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      // 일기 확장 필드
      'diaryTitle': diaryTitle,
      'diaryContent': diaryContent,
      'rating': rating,
      'mood': mood?.name,
      'mvpPlayerId': mvpPlayerId,
      'mvpPlayerName': mvpPlayerName,
      'tags': tags,
      'weather': weather,
      'companion': companion,
      'ticketPrice': ticketPrice,
      'foodReview': foodReview,
      'isFavorite': isFavorite,
      'supportedTeamId': supportedTeamId,
    };
  }

  AttendanceRecord copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? league,
    String? homeTeamId,
    String? homeTeamName,
    String? homeTeamLogo,
    String? awayTeamId,
    String? awayTeamName,
    String? awayTeamLogo,
    String? stadium,
    String? seatInfo,
    int? homeScore,
    int? awayScore,
    String? memo,
    List<String>? photos,
    double? latitude,
    double? longitude,
    String? matchId,
    DateTime? createdAt,
    DateTime? updatedAt,
    // 일기 확장 필드
    String? diaryTitle,
    String? diaryContent,
    double? rating,
    MatchMood? mood,
    String? mvpPlayerId,
    String? mvpPlayerName,
    List<String>? tags,
    String? weather,
    String? companion,
    int? ticketPrice,
    String? foodReview,
    bool? isFavorite,
    String? supportedTeamId,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      league: league ?? this.league,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      homeTeamName: homeTeamName ?? this.homeTeamName,
      homeTeamLogo: homeTeamLogo ?? this.homeTeamLogo,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      awayTeamName: awayTeamName ?? this.awayTeamName,
      awayTeamLogo: awayTeamLogo ?? this.awayTeamLogo,
      stadium: stadium ?? this.stadium,
      seatInfo: seatInfo ?? this.seatInfo,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      memo: memo ?? this.memo,
      photos: photos ?? this.photos,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      matchId: matchId ?? this.matchId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // 일기 확장 필드
      diaryTitle: diaryTitle ?? this.diaryTitle,
      diaryContent: diaryContent ?? this.diaryContent,
      rating: rating ?? this.rating,
      mood: mood ?? this.mood,
      mvpPlayerId: mvpPlayerId ?? this.mvpPlayerId,
      mvpPlayerName: mvpPlayerName ?? this.mvpPlayerName,
      tags: tags ?? this.tags,
      weather: weather ?? this.weather,
      companion: companion ?? this.companion,
      ticketPrice: ticketPrice ?? this.ticketPrice,
      foodReview: foodReview ?? this.foodReview,
      isFavorite: isFavorite ?? this.isFavorite,
      supportedTeamId: supportedTeamId ?? this.supportedTeamId,
    );
  }

  /// 내가 응원한 팀 기준 경기 결과
  MatchResult get myResult {
    if (supportedTeamId == null) return MatchResult.unknown;
    return getResultForTeam(supportedTeamId!);
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    date,
    league,
    homeTeamId,
    awayTeamId,
    stadium,
    homeScore,
    awayScore,
  ];

  // Example dummy data
  static List<AttendanceRecord> dummyRecords() {
    return [
      AttendanceRecord(
        id: 'att_001',
        userId: 'user_001',
        date: DateTime(2024, 11, 23),
        league: 'EPL',
        homeTeamId: 'team_tottenham',
        homeTeamName: 'Tottenham',
        awayTeamId: 'team_mancity',
        awayTeamName: 'Man City',
        stadium: 'Tottenham Hotspur Stadium',
        seatInfo: 'Block 112, Row 15, Seat 234',
        homeScore: 2,
        awayScore: 1,
        memo: 'e !   X  =%',
        photos: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AttendanceRecord(
        id: 'att_002',
        userId: 'user_001',
        date: DateTime(2024, 10, 15),
        league: 'K-League',
        homeTeamId: 'team_fcseoul',
        homeTeamName: 'FC Seoul',
        awayTeamId: 'team_jeonbuk',
        awayTeamName: 'Jeonbuk',
        stadium: '0',
        seatInfo: 'El 22',
        homeScore: 3,
        awayScore: 0,
        memo: 'K   ',
        photos: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      AttendanceRecord(
        id: 'att_003',
        userId: 'user_001',
        date: DateTime(2024, 9, 5),
        league: 'UCL',
        homeTeamId: 'team_realmadrid',
        homeTeamName: 'Real Madrid',
        awayTeamId: 'team_bayern',
        awayTeamName: 'Bayern Munich',
        stadium: 'Santiago Bernabu',
        seatInfo: 'Tribune Est, Section 205',
        homeScore: 2,
        awayScore: 2,
        memo: 't  )8! Xx 0',
        photos: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

/// Statistics model for attendance
class AttendanceStats {
  final int totalMatches;
  final int wins;
  final int draws;
  final int losses;
  final Map<String, int> stadiumVisits;
  final Map<String, int> leagueCount;
  final Map<String, TeamStats> teamStats;

  const AttendanceStats({
    this.totalMatches = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.stadiumVisits = const {},
    this.leagueCount = const {},
    this.teamStats = const {},
  });

  double get winRate => totalMatches > 0 ? (wins / totalMatches) * 100 : 0;

  factory AttendanceStats.fromRecords(
    List<AttendanceRecord> records,
    String? favoriteTeamId,
  ) {
    int wins = 0;
    int draws = 0;
    int losses = 0;
    final stadiumVisits = <String, int>{};
    final leagueCount = <String, int>{};
    final teamStats = <String, TeamStats>{};

    for (final record in records) {
      // Stadium visits
      stadiumVisits[record.stadium] = (stadiumVisits[record.stadium] ?? 0) + 1;

      // League count
      leagueCount[record.league] = (leagueCount[record.league] ?? 0) + 1;

      // Win/Draw/Loss - supportedTeamId가 있으면 그것 기준, 없으면 favoriteTeamId 기준
      final teamIdForResult = record.supportedTeamId ?? favoriteTeamId;
      if (teamIdForResult != null) {
        final result = record.getResultForTeam(teamIdForResult);
        switch (result) {
          case MatchResult.win:
            wins++;
            break;
          case MatchResult.draw:
            draws++;
            break;
          case MatchResult.loss:
            losses++;
            break;
          case MatchResult.unknown:
            break;
        }
      }

      // Team-specific stats
      for (final teamId in [record.homeTeamId, record.awayTeamId]) {
        final teamName = teamId == record.homeTeamId
            ? record.homeTeamName
            : record.awayTeamName;
        final existing = teamStats[teamId];
        final result = record.getResultForTeam(teamId);

        teamStats[teamId] = TeamStats(
          teamId: teamId,
          teamName: teamName,
          matchesAttended: (existing?.matchesAttended ?? 0) + 1,
          wins: (existing?.wins ?? 0) + (result == MatchResult.win ? 1 : 0),
          draws: (existing?.draws ?? 0) + (result == MatchResult.draw ? 1 : 0),
          losses:
              (existing?.losses ?? 0) + (result == MatchResult.loss ? 1 : 0),
        );
      }
    }

    return AttendanceStats(
      totalMatches: records.length,
      wins: wins,
      draws: draws,
      losses: losses,
      stadiumVisits: stadiumVisits,
      leagueCount: leagueCount,
      teamStats: teamStats,
    );
  }
}

class TeamStats {
  final String teamId;
  final String teamName;
  final int matchesAttended;
  final int wins;
  final int draws;
  final int losses;

  const TeamStats({
    required this.teamId,
    required this.teamName,
    this.matchesAttended = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
  });

  double get winRate =>
      matchesAttended > 0 ? (wins / matchesAttended) * 100 : 0;
}
