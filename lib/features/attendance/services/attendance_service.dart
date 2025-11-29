import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../models/attendance_record.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.attendanceCollection);

  // Get attendance list for user
  Stream<List<AttendanceRecord>> getAttendanceList(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceRecord.fromFirestore(doc))
            .toList());
  }

  // Get attendance list (Future)
  Future<List<AttendanceRecord>> getAttendanceListOnce(String userId) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceRecord.fromFirestore(doc))
        .toList();
  }

  // Get single attendance record
  Future<AttendanceRecord?> getAttendanceDetail(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return AttendanceRecord.fromFirestore(doc);
  }

  // Stream single attendance record
  Stream<AttendanceRecord?> attendanceDetailStream(String id) {
    return _collection.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AttendanceRecord.fromFirestore(doc);
    });
  }

  // Add attendance record
  Future<String> addAttendance(AttendanceRecord record) async {
    final docRef = await _collection.add(record.toFirestore());
    return docRef.id;
  }

  // Update attendance record
  Future<void> updateAttendance(AttendanceRecord record) async {
    await _collection.doc(record.id).update({
      ...record.toFirestore(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Delete attendance record
  Future<void> deleteAttendance(String id) async {
    await _collection.doc(id).delete();
  }

  // Get attendance count by year
  Future<int> getAttendanceCountByYear(String userId, int year) async {
    final startOfYear = DateTime(year, 1, 1);
    final endOfYear = DateTime(year + 1, 1, 1);

    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYear))
        .where('date', isLessThan: Timestamp.fromDate(endOfYear))
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  // Get attendance statistics
  Future<AttendanceStats> getAttendanceStats(
    String userId, {
    String? favoriteTeamId,
  }) async {
    final records = await getAttendanceListOnce(userId);
    return AttendanceStats.fromRecords(records, favoriteTeamId);
  }

  // Get attendances by stadium
  Future<List<AttendanceRecord>> getAttendancesByStadium(
    String userId,
    String stadium,
  ) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('stadium', isEqualTo: stadium)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceRecord.fromFirestore(doc))
        .toList();
  }

  // Get attendances by team
  Future<List<AttendanceRecord>> getAttendancesByTeam(
    String userId,
    String teamId,
  ) async {
    // Firebase doesn't support OR queries directly, so we need two queries
    final homeSnapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('homeTeamId', isEqualTo: teamId)
        .get();

    final awaySnapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('awayTeamId', isEqualTo: teamId)
        .get();

    final allDocs = [...homeSnapshot.docs, ...awaySnapshot.docs];
    final records =
        allDocs.map((doc) => AttendanceRecord.fromFirestore(doc)).toList();

    // Sort by date
    records.sort((a, b) => b.date.compareTo(a.date));

    // Remove duplicates (in case a team plays against itself, which is impossible but safe)
    final seen = <String>{};
    return records.where((record) => seen.add(record.id)).toList();
  }

  // Get attendances by league
  Future<List<AttendanceRecord>> getAttendancesByLeague(
    String userId,
    String league,
  ) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .where('league', isEqualTo: league)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AttendanceRecord.fromFirestore(doc))
        .toList();
  }

  // Search attendances
  Future<List<AttendanceRecord>> searchAttendances(
    String userId,
    String query,
  ) async {
    // Firebase doesn't support full-text search
    // This is a basic implementation - for production, consider Algolia or similar
    final records = await getAttendanceListOnce(userId);

    final lowerQuery = query.toLowerCase();
    return records.where((record) {
      return record.homeTeamName.toLowerCase().contains(lowerQuery) ||
          record.awayTeamName.toLowerCase().contains(lowerQuery) ||
          record.stadium.toLowerCase().contains(lowerQuery) ||
          record.league.toLowerCase().contains(lowerQuery) ||
          (record.memo?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
