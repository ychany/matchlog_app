import 'package:cloud_firestore/cloud_firestore.dart';
import '../../attendance/models/attendance_record.dart';

class UserProfile {
  final String id;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final String? favoriteTeamId;
  final String? favoriteTeamName;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.favoriteTeamId,
    this.favoriteTeamName,
    this.createdAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserProfile(id: doc.id, displayName: '익명');
    }
    return UserProfile(
      id: doc.id,
      displayName: data['displayName'] ?? data['name'] ?? '익명',
      photoUrl: data['photoUrl'] ?? data['photoURL'],
      bio: data['bio'],
      favoriteTeamId: data['favoriteTeamId'],
      favoriteTeamName: data['favoriteTeamName'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자 프로필 조회
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) {
      return null;
    }
    return UserProfile.fromFirestore(doc);
  }

  // 사용자의 직관 기록 조회 (공개 프로필용)
  Future<List<AttendanceRecord>> getUserAttendanceRecords(String userId, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection('attendance_records')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceRecord.fromFirestore(doc))
        .toList();
  }

  // 사용자 통계 조회
  Future<AttendanceStats> getUserStats(String userId, {String? favoriteTeamId}) async {
    final records = await getUserAttendanceRecords(userId, limit: 1000);
    return AttendanceStats.fromRecords(records, favoriteTeamId);
  }

  // 사용자의 게시글 수 조회
  Future<int> getUserPostCount(String userId) async {
    final snapshot = await _firestore
        .collection('posts')
        .where('authorId', isEqualTo: userId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
