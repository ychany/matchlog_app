import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';
import '../../auth/providers/auth_provider.dart';

// Attendance Service Provider
final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService();
});

// Attendance List Provider
final attendanceListProvider = StreamProvider<List<AttendanceRecord>>((ref) {
  final service = ref.watch(attendanceServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return Stream.value([]);
  return service.getAttendanceList(userId);
});

// Attendance Stats Provider
final attendanceStatsProvider = FutureProvider<AttendanceStats>((ref) async {
  final service = ref.watch(attendanceServiceProvider);
  final userId = ref.watch(currentUserIdProvider);
  final userModel = ref.watch(userModelProvider).value;

  if (userId == null) {
    return const AttendanceStats();
  }

  final favoriteTeamId = userModel?.favoriteTeamIds.isNotEmpty == true
      ? userModel!.favoriteTeamIds.first
      : null;

  return service.getAttendanceStats(userId, favoriteTeamId: favoriteTeamId);
});

// Single Attendance Detail Provider
final attendanceDetailProvider =
    StreamProvider.family<AttendanceRecord?, String>((ref, id) {
  final service = ref.watch(attendanceServiceProvider);
  return service.attendanceDetailStream(id);
});

// Attendance Notifier for actions
class AttendanceNotifier extends StateNotifier<AsyncValue<void>> {
  final AttendanceService _service;
  final Ref _ref;

  AttendanceNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  Future<String?> addAttendance(AttendanceRecord record) async {
    state = const AsyncValue.loading();
    try {
      final id = await _service.addAttendance(record);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> updateAttendance(AttendanceRecord record) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateAttendance(record);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteAttendance(String id) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteAttendance(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final attendanceNotifierProvider =
    StateNotifierProvider<AttendanceNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(attendanceServiceProvider);
  return AttendanceNotifier(service, ref);
});

// Filtered Attendance Providers
final attendanceByStadiumProvider =
    FutureProvider.family<List<AttendanceRecord>, String>((ref, stadium) async {
  final service = ref.watch(attendanceServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return [];
  return service.getAttendancesByStadium(userId, stadium);
});

final attendanceByTeamProvider =
    FutureProvider.family<List<AttendanceRecord>, String>((ref, teamId) async {
  final service = ref.watch(attendanceServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return [];
  return service.getAttendancesByTeam(userId, teamId);
});

final attendanceByLeagueProvider =
    FutureProvider.family<List<AttendanceRecord>, String>((ref, league) async {
  final service = ref.watch(attendanceServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return [];
  return service.getAttendancesByLeague(userId, league);
});

// Search Provider
final attendanceSearchProvider =
    FutureProvider.family<List<AttendanceRecord>, String>((ref, query) async {
  final service = ref.watch(attendanceServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null || query.isEmpty) return [];
  return service.searchAttendances(userId, query);
});

// Attendance Count by Year Provider
final attendanceCountByYearProvider =
    FutureProvider.family<int, int>((ref, year) async {
  final service = ref.watch(attendanceServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return 0;
  return service.getAttendanceCountByYear(userId, year);
});
