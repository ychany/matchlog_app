import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final List<String> favoriteTeamIds;
  final List<String> favoritePlayerIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.favoriteTeamIds = const [],
    this.favoritePlayerIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Timestamp 안전하게 파싱하는 헬퍼 함수
    DateTime parseTimestamp(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      favoriteTeamIds: List<String>.from(data['favoriteTeamIds'] ?? []),
      favoritePlayerIds: List<String>.from(data['favoritePlayerIds'] ?? []),
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'favoriteTeamIds': favoriteTeamIds,
      'favoritePlayerIds': favoritePlayerIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? favoriteTeamIds,
    List<String>? favoritePlayerIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteTeamIds: favoriteTeamIds ?? this.favoriteTeamIds,
      favoritePlayerIds: favoritePlayerIds ?? this.favoritePlayerIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        favoriteTeamIds,
        favoritePlayerIds,
        createdAt,
        updatedAt,
      ];

  // Example dummy data
  static UserModel dummy() {
    return UserModel(
      uid: 'user_001',
      email: 'fan@example.com',
      displayName: 'l,',
      photoUrl: null,
      favoriteTeamIds: ['team_mancity', 'team_tottenham'],
      favoritePlayerIds: ['player_son', 'player_haaland'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
