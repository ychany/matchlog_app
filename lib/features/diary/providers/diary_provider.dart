import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';
import '../../auth/providers/auth_provider.dart';

// Diary Service Provider
final diaryServiceProvider = Provider<DiaryService>((ref) {
  return DiaryService();
});

// Diary List Provider
final diaryListProvider = StreamProvider<List<DiaryEntry>>((ref) {
  final service = ref.watch(diaryServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return Stream.value([]);
  return service.getDiaryList(userId);
});

// Diary Entry by ID Provider
final diaryEntryProvider =
    FutureProvider.family<DiaryEntry?, String>((ref, id) async {
  final service = ref.watch(diaryServiceProvider);
  return service.getDiaryEntry(id);
});

// Diary Entry by Match ID Provider
final diaryEntryByMatchProvider =
    FutureProvider.family<DiaryEntry?, String>((ref, matchId) async {
  final service = ref.watch(diaryServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return null;
  return service.getDiaryEntryByMatch(userId, matchId);
});

// Has Diary Entry Provider
final hasDiaryEntryProvider =
    FutureProvider.family<bool, String>((ref, matchId) async {
  final service = ref.watch(diaryServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return false;
  return service.hasDiaryEntry(userId, matchId);
});

// Yearly Summary Provider
final yearlySummaryProvider =
    FutureProvider.family<DiarySummary, int>((ref, year) async {
  final service = ref.watch(diaryServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return DiarySummary(year: year);
  return service.getYearlySummary(userId, year);
});

// Current Year Summary
final currentYearSummaryProvider = FutureProvider<DiarySummary>((ref) async {
  final year = DateTime.now().year;
  return ref.watch(yearlySummaryProvider(year).future);
});

// Average Rating Provider
final averageRatingProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(diaryServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return 0;
  return service.getAverageRating(userId);
});

// Highest Rated Matches Provider
final highestRatedMatchesProvider =
    FutureProvider<List<DiaryEntry>>((ref) async {
  final service = ref.watch(diaryServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return [];
  return service.getHighestRatedMatches(userId, limit: 5);
});

// Diary Notifier for actions
class DiaryNotifier extends StateNotifier<AsyncValue<void>> {
  final DiaryService _service;
  final Ref _ref;

  DiaryNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  Future<String?> addDiaryEntry(DiaryEntry entry) async {
    state = const AsyncValue.loading();
    try {
      final id = await _service.addDiaryEntry(entry);
      state = const AsyncValue.data(null);
      return id;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> updateDiaryEntry(DiaryEntry entry) async {
    state = const AsyncValue.loading();
    try {
      await _service.updateDiaryEntry(entry);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteDiaryEntry(String id) async {
    state = const AsyncValue.loading();
    try {
      await _service.deleteDiaryEntry(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final diaryNotifierProvider =
    StateNotifierProvider<DiaryNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(diaryServiceProvider);
  return DiaryNotifier(service, ref);
});

// Diary Entries by League
final diaryByLeagueProvider =
    FutureProvider.family<List<DiaryEntry>, String>((ref, league) async {
  final service = ref.watch(diaryServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return [];
  return service.getDiaryEntriesByLeague(userId, league);
});

// Diary Entries by Team
final diaryByTeamProvider =
    FutureProvider.family<List<DiaryEntry>, String>((ref, teamId) async {
  final service = ref.watch(diaryServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return [];
  return service.getDiaryEntriesByTeam(userId, teamId);
});

// Diary Count by Year
final diaryCountByYearProvider =
    FutureProvider.family<int, int>((ref, year) async {
  final service = ref.watch(diaryServiceProvider);
  final userId = ref.watch(currentUserIdProvider);

  if (userId == null) return 0;
  return service.getDiaryCountByYear(userId, year);
});
