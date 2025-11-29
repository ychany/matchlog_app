import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotificationSetting extends Equatable {
  final String id;
  final String userId;
  final String matchId;
  final bool notifyKickoff;
  final bool notifyLineup;
  final bool notifyResult;
  final DateTime? createdAt;

  const NotificationSetting({
    required this.id,
    required this.userId,
    required this.matchId,
    this.notifyKickoff = true,
    this.notifyLineup = false,
    this.notifyResult = true,
    this.createdAt,
  });

  factory NotificationSetting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationSetting(
      id: doc.id,
      userId: data['userId'] as String,
      matchId: data['matchId'] as String,
      notifyKickoff: data['notifyKickoff'] as bool? ?? true,
      notifyLineup: data['notifyLineup'] as bool? ?? false,
      notifyResult: data['notifyResult'] as bool? ?? true,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'matchId': matchId,
      'notifyKickoff': notifyKickoff,
      'notifyLineup': notifyLineup,
      'notifyResult': notifyResult,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  NotificationSetting copyWith({
    String? id,
    String? userId,
    String? matchId,
    bool? notifyKickoff,
    bool? notifyLineup,
    bool? notifyResult,
    DateTime? createdAt,
  }) {
    return NotificationSetting(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      matchId: matchId ?? this.matchId,
      notifyKickoff: notifyKickoff ?? this.notifyKickoff,
      notifyLineup: notifyLineup ?? this.notifyLineup,
      notifyResult: notifyResult ?? this.notifyResult,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get hasAnyNotification => notifyKickoff || notifyLineup || notifyResult;

  @override
  List<Object?> get props => [
        id,
        userId,
        matchId,
        notifyKickoff,
        notifyLineup,
        notifyResult,
      ];
}

/// Global notification preferences for user
class UserNotificationPreferences extends Equatable {
  final String userId;
  final bool enablePushNotifications;
  final bool notifyFavoriteTeamMatches;
  final bool notifyFavoritePlayerNews;
  final int minutesBeforeKickoff;
  final List<String> mutedLeagues;

  const UserNotificationPreferences({
    required this.userId,
    this.enablePushNotifications = true,
    this.notifyFavoriteTeamMatches = true,
    this.notifyFavoritePlayerNews = true,
    this.minutesBeforeKickoff = 30,
    this.mutedLeagues = const [],
  });

  factory UserNotificationPreferences.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserNotificationPreferences(
      userId: doc.id,
      enablePushNotifications: data['enablePushNotifications'] as bool? ?? true,
      notifyFavoriteTeamMatches:
          data['notifyFavoriteTeamMatches'] as bool? ?? true,
      notifyFavoritePlayerNews:
          data['notifyFavoritePlayerNews'] as bool? ?? true,
      minutesBeforeKickoff: data['minutesBeforeKickoff'] as int? ?? 30,
      mutedLeagues: List<String>.from(data['mutedLeagues'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'enablePushNotifications': enablePushNotifications,
      'notifyFavoriteTeamMatches': notifyFavoriteTeamMatches,
      'notifyFavoritePlayerNews': notifyFavoritePlayerNews,
      'minutesBeforeKickoff': minutesBeforeKickoff,
      'mutedLeagues': mutedLeagues,
    };
  }

  UserNotificationPreferences copyWith({
    String? userId,
    bool? enablePushNotifications,
    bool? notifyFavoriteTeamMatches,
    bool? notifyFavoritePlayerNews,
    int? minutesBeforeKickoff,
    List<String>? mutedLeagues,
  }) {
    return UserNotificationPreferences(
      userId: userId ?? this.userId,
      enablePushNotifications:
          enablePushNotifications ?? this.enablePushNotifications,
      notifyFavoriteTeamMatches:
          notifyFavoriteTeamMatches ?? this.notifyFavoriteTeamMatches,
      notifyFavoritePlayerNews:
          notifyFavoritePlayerNews ?? this.notifyFavoritePlayerNews,
      minutesBeforeKickoff: minutesBeforeKickoff ?? this.minutesBeforeKickoff,
      mutedLeagues: mutedLeagues ?? this.mutedLeagues,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        enablePushNotifications,
        notifyFavoriteTeamMatches,
        notifyFavoritePlayerNews,
        minutesBeforeKickoff,
        mutedLeagues,
      ];
}
