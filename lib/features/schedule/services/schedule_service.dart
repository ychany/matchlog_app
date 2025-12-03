import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/sports_db_service.dart';
import '../../../shared/models/match_model.dart';
import '../models/notification_setting.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SportsDbService _sportsDbService = SportsDbService();

  CollectionReference<Map<String, dynamic>> get _schedulesCollection =>
      _firestore.collection(AppConstants.schedulesCollection);

  CollectionReference<Map<String, dynamic>> get _notificationCollection =>
      _firestore.collection(AppConstants.notificationSettingsCollection);

  // Get schedules by date range
  Stream<List<Match>> getSchedules({
    required DateTime startDate,
    required DateTime endDate,
    String? league,
    List<String>? favoriteTeamIds,
  }) {
    Query<Map<String, dynamic>> query = _schedulesCollection
        .where('kickoff',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('kickoff', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('kickoff');

    if (league != null) {
      query = query.where('league', isEqualTo: league);
    }

    return query.snapshots().map((snapshot) {
      final matches =
          snapshot.docs.map((doc) => Match.fromFirestore(doc)).toList();

      // Sort: followed teams first, then by kickoff time
      if (favoriteTeamIds != null && favoriteTeamIds.isNotEmpty) {
        matches.sort((a, b) {
          final aFollowed = favoriteTeamIds.contains(a.homeTeamId) ||
              favoriteTeamIds.contains(a.awayTeamId);
          final bFollowed = favoriteTeamIds.contains(b.homeTeamId) ||
              favoriteTeamIds.contains(b.awayTeamId);

          if (aFollowed && !bFollowed) return -1;
          if (!aFollowed && bFollowed) return 1;
          return a.kickoff.compareTo(b.kickoff);
        });
      }

      return matches;
    });
  }

  // Get schedules for a specific date (using SportsDB API)
  Future<List<Match>> getSchedulesByDate(
    DateTime date, {
    List<String>? favoriteTeamIds,
  }) async {
    try {
      // SportsDB API에서 경기 데이터 가져오기
      final events = await _sportsDbService.getEventsByDate(date, sport: 'Soccer');

      // SportsDbEvent를 Match로 변환
      final matches = events.map((event) => _convertEventToMatch(event)).toList();

      if (favoriteTeamIds != null && favoriteTeamIds.isNotEmpty) {
        matches.sort((a, b) {
          final aFollowed = favoriteTeamIds.contains(a.homeTeamId) ||
              favoriteTeamIds.contains(a.awayTeamId);
          final bFollowed = favoriteTeamIds.contains(b.homeTeamId) ||
              favoriteTeamIds.contains(b.awayTeamId);

          if (aFollowed && !bFollowed) return -1;
          if (!aFollowed && bFollowed) return 1;
          return a.kickoff.compareTo(b.kickoff);
        });
      }

      return matches;
    } catch (e) {
      // API 오류 시 Firestore fallback
      return _getSchedulesByDateFromFirestore(date, favoriteTeamIds: favoriteTeamIds);
    }
  }

  // Firestore에서 경기 데이터 가져오기 (fallback)
  Future<List<Match>> _getSchedulesByDateFromFirestore(
    DateTime date, {
    List<String>? favoriteTeamIds,
  }) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _schedulesCollection
        .where('kickoff',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('kickoff', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('kickoff')
        .get();

    final matches =
        snapshot.docs.map((doc) => Match.fromFirestore(doc)).toList();

    if (favoriteTeamIds != null && favoriteTeamIds.isNotEmpty) {
      matches.sort((a, b) {
        final aFollowed = favoriteTeamIds.contains(a.homeTeamId) ||
            favoriteTeamIds.contains(a.awayTeamId);
        final bFollowed = favoriteTeamIds.contains(b.homeTeamId) ||
            favoriteTeamIds.contains(b.awayTeamId);

        if (aFollowed && !bFollowed) return -1;
        if (!aFollowed && bFollowed) return 1;
        return a.kickoff.compareTo(b.kickoff);
      });
    }

    return matches;
  }

  // SportsDbEvent를 Match로 변환
  Match _convertEventToMatch(SportsDbEvent event) {
    return Match(
      id: event.id,
      league: event.league ?? '',
      homeTeamId: event.homeTeamId ?? '',
      homeTeamName: event.homeTeam ?? '',
      homeTeamLogo: event.homeTeamBadge,
      awayTeamId: event.awayTeamId ?? '',
      awayTeamName: event.awayTeam ?? '',
      awayTeamLogo: event.awayTeamBadge,
      kickoff: event.dateTime ?? DateTime.now(),
      stadium: event.venue ?? '',
      homeScore: event.homeScore,
      awayScore: event.awayScore,
      status: _convertStatus(event.status, event.isFinished),
    );
  }

  // API 상태를 MatchStatus enum으로 변환
  MatchStatus _convertStatus(String? apiStatus, bool isFinished) {
    if (isFinished) return MatchStatus.finished;

    switch (apiStatus?.toUpperCase()) {
      case 'FT':
      case 'AET':
      case 'PEN':
        return MatchStatus.finished;
      case 'LIVE':
      case '1H':
      case '2H':
      case 'HT':
      case 'ET':
        return MatchStatus.live;
      case 'PST':
      case 'POSTP':
        return MatchStatus.postponed;
      case 'CANC':
      case 'ABD':
        return MatchStatus.cancelled;
      default:
        return MatchStatus.scheduled;
    }
  }

  // Get upcoming matches for favorite teams
  Future<List<Match>> getUpcomingMatchesForTeams(
    List<String> teamIds, {
    int limit = 10,
  }) async {
    if (teamIds.isEmpty) return [];

    final now = DateTime.now();
    final matches = <Match>[];

    // Query for home and away matches
    for (final teamId in teamIds) {
      final homeSnapshot = await _schedulesCollection
          .where('homeTeamId', isEqualTo: teamId)
          .where('kickoff', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('kickoff')
          .limit(limit)
          .get();

      final awaySnapshot = await _schedulesCollection
          .where('awayTeamId', isEqualTo: teamId)
          .where('kickoff', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
          .orderBy('kickoff')
          .limit(limit)
          .get();

      matches.addAll(homeSnapshot.docs.map((doc) => Match.fromFirestore(doc)));
      matches.addAll(awaySnapshot.docs.map((doc) => Match.fromFirestore(doc)));
    }

    // Remove duplicates and sort
    final seen = <String>{};
    final uniqueMatches =
        matches.where((match) => seen.add(match.id)).toList();
    uniqueMatches.sort((a, b) => a.kickoff.compareTo(b.kickoff));

    return uniqueMatches.take(limit).toList();
  }

  // Get match by ID
  Future<Match?> getMatch(String matchId) async {
    final doc = await _schedulesCollection.doc(matchId).get();
    if (!doc.exists) return null;
    return Match.fromFirestore(doc);
  }

  // Get matches by league
  Future<List<Match>> getMatchesByLeague(
    String league, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query<Map<String, dynamic>> query =
        _schedulesCollection.where('league', isEqualTo: league);

    if (startDate != null) {
      query = query.where('kickoff',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query =
          query.where('kickoff', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.orderBy('kickoff').get();
    return snapshot.docs.map((doc) => Match.fromFirestore(doc)).toList();
  }

  // === Notification Settings ===

  // Get notification setting for a match
  Future<NotificationSetting?> getNotificationSetting(
    String userId,
    String matchId,
  ) async {
    final snapshot = await _notificationCollection
        .where('userId', isEqualTo: userId)
        .where('matchId', isEqualTo: matchId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return NotificationSetting.fromFirestore(snapshot.docs.first);
  }

  // Set notification for a match
  Future<void> setNotification({
    required String userId,
    required String matchId,
    bool notifyKickoff = true,
    bool notifyLineup = false,
    bool notifyResult = true,
  }) async {
    final existing = await getNotificationSetting(userId, matchId);

    final setting = NotificationSetting(
      id: existing?.id ?? '',
      userId: userId,
      matchId: matchId,
      notifyKickoff: notifyKickoff,
      notifyLineup: notifyLineup,
      notifyResult: notifyResult,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    if (existing != null) {
      await _notificationCollection.doc(existing.id).update(setting.toFirestore());
    } else {
      await _notificationCollection.add(setting.toFirestore());
    }
  }

  // Toggle specific notification type
  Future<void> toggleNotification({
    required String userId,
    required String matchId,
    required String type, // 'kickoff', 'lineup', 'result'
    required bool value,
  }) async {
    final existing = await getNotificationSetting(userId, matchId);

    if (existing != null) {
      final updates = <String, dynamic>{};
      switch (type) {
        case 'kickoff':
          updates['notifyKickoff'] = value;
          break;
        case 'lineup':
          updates['notifyLineup'] = value;
          break;
        case 'result':
          updates['notifyResult'] = value;
          break;
      }
      await _notificationCollection.doc(existing.id).update(updates);
    } else {
      // Create new setting with default values
      await setNotification(
        userId: userId,
        matchId: matchId,
        notifyKickoff: type == 'kickoff' ? value : true,
        notifyLineup: type == 'lineup' ? value : false,
        notifyResult: type == 'result' ? value : true,
      );
    }
  }

  // Remove notification setting
  Future<void> removeNotification(String userId, String matchId) async {
    final existing = await getNotificationSetting(userId, matchId);
    if (existing != null) {
      await _notificationCollection.doc(existing.id).delete();
    }
  }

  // Get all notification settings for user
  Future<List<NotificationSetting>> getUserNotificationSettings(
      String userId) async {
    final snapshot = await _notificationCollection
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => NotificationSetting.fromFirestore(doc))
        .toList();
  }

  // Check if user has notification for match
  Future<bool> hasNotification(String userId, String matchId) async {
    final setting = await getNotificationSetting(userId, matchId);
    return setting != null && setting.hasAnyNotification;
  }
}
