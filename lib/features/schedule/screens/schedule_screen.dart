import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/sports_db_service.dart';
import '../../../shared/models/match_model.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/schedule_provider.dart';
import '../../diary/providers/diary_provider.dart';

/// 축구 라이브스코어 Provider
final scheduleLivescoresProvider =
    FutureProvider<List<SportsDbLiveEvent>>((ref) async {
  final service = SportsDbService();
  return service.getSoccerLivescores();
});

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  static const _primary = Color(0xFF2563EB);
  static const _primaryLight = Color(0xFFDBEAFE);
  static const _success = Color(0xFF10B981);
  static const _error = Color(0xFFEF4444);
  static const _textPrimary = Color(0xFF111827);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);
  static const _background = Color(0xFFF9FAFB);

  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedLeague = ref.watch(selectedLeagueProvider);
    final schedulesAsync = ref.watch(filteredSchedulesProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: Column(
            children: [
              // 헤더
              _buildHeader(),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 캘린더
                      _buildCalendar(selectedDate),

                      const SizedBox(height: 12),

                      // 리그 필터
                      _buildLeagueFilter(selectedLeague),

                      const SizedBox(height: 16),

                      // 라이브 스코어
                      _ScheduleLiveScoresSection(),

                      // 경기 목록
                      _buildMatchList(schedulesAsync),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '경기 일정',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(selectedDateProvider.notifier).state = DateTime.now();
              setState(() => _focusedDay = DateTime.now());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.today, size: 18, color: _primary),
                  const SizedBox(width: 6),
                  Text(
                    '오늘',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(DateTime selectedDate) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          ref.read(selectedDateProvider.notifier).state = selectedDay;
          setState(() => _focusedDay = focusedDay);
        },
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: _primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: _primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: _primary,
            fontWeight: FontWeight.w600,
          ),
          defaultTextStyle: const TextStyle(color: _textPrimary),
          weekendTextStyle: TextStyle(color: _error.withValues(alpha: 0.8)),
          outsideTextStyle: TextStyle(color: _textSecondary.withValues(alpha: 0.5)),
          markerDecoration: const BoxDecoration(
            color: _success,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
          formatButtonDecoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(8),
          ),
          formatButtonTextStyle: const TextStyle(
            color: _textSecondary,
            fontSize: 12,
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: _textSecondary),
          rightChevronIcon:
              const Icon(Icons.chevron_right, color: _textSecondary),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: _textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          weekendStyle: TextStyle(
            color: _error,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLeagueFilter(String? selectedLeague) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _LeagueChip(
            label: '전체',
            isSelected: selectedLeague == null,
            onTap: () {
              ref.read(selectedLeagueProvider.notifier).state = null;
            },
          ),
          ...AppConstants.supportedLeagues.map(
            (league) => _LeagueChip(
              label: league,
              displayLabel: AppConstants.getLeagueDisplayName(league),
              isSelected: selectedLeague == league,
              onTap: () {
                ref.read(selectedLeagueProvider.notifier).state = league;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(AsyncValue<List<Match>> schedulesAsync) {
    return schedulesAsync.when(
      data: (matches) {
        if (matches.isEmpty) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: const EmptyScheduleState(),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: matches
                .map((match) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ScheduleMatchCard(match: match),
                    ))
                .toList(),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: LoadingIndicator(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16),
        child: ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(filteredSchedulesProvider),
        ),
      ),
    );
  }
}

class _LeagueChip extends StatelessWidget {
  final String label;
  final String? displayLabel;
  final bool isSelected;
  final VoidCallback onTap;

  static const _primary = Color(0xFF2563EB);
  static const _border = Color(0xFFE5E7EB);

  const _LeagueChip({
    required this.label,
    this.displayLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? _primary : _border,
            ),
          ),
          child: Text(
            displayLabel ?? label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleMatchCard extends ConsumerWidget {
  final Match match;

  static const _primary = Color(0xFF2563EB);
  static const _primaryLight = Color(0xFFDBEAFE);
  static const _success = Color(0xFF10B981);
  static const _textPrimary = Color(0xFF111827);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);

  const _ScheduleMatchCard({required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNotificationAsync = ref.watch(hasNotificationProvider(match.id));
    final hasDiaryAsync = ref.watch(hasDiaryEntryProvider(match.id));

    return GestureDetector(
      onTap: () => context.push('/match/${match.id}'),
      onLongPress: () => _showMatchOptions(context, ref),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Column(
          children: [
            // 리그 & 시간 & 알림
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppConstants.getLeagueDisplayName(match.league),
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        DateFormat('HH:mm').format(match.kickoff),
                        style: const TextStyle(
                          color: _primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                hasNotificationAsync.when(
                  data: (hasNotification) => GestureDetector(
                    onTap: () => _toggleNotification(ref, hasNotification),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: hasNotification
                            ? _primary.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasNotification
                            ? Icons.notifications_active
                            : Icons.notifications_none_outlined,
                        size: 16,
                        color: hasNotification ? _primary : _textSecondary,
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => Icon(
                    Icons.notifications_none_outlined,
                    size: 16,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 팀 정보
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildTeamLogo(match.homeTeamLogo),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          match.homeTeamName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: match.isFinished
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _textPrimary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            match.scoreDisplay,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _textSecondary,
                          ),
                        ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          match.awayTeamName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTeamLogo(match.awayTeamLogo),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 경기장 & 중계
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.stadium_outlined,
                    size: 12,
                    color: _textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      match.stadium,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (match.broadcast != null) ...[
                    Container(
                      width: 1,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: _textSecondary.withValues(alpha: 0.3),
                    ),
                    Icon(Icons.tv, size: 12, color: _textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      match.broadcast!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: _textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 직관 완료 표시
            hasDiaryAsync.when(
              data: (hasDiary) {
                if (hasDiary) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: _success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '직관 완료',
                            style: TextStyle(
                              color: _success,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleNotification(WidgetRef ref, bool currentValue) {
    if (currentValue) {
      ref.read(scheduleNotifierProvider.notifier).removeNotification(match.id);
    } else {
      ref
          .read(scheduleNotifierProvider.notifier)
          .setNotification(matchId: match.id);
    }
  }

  Widget _buildTeamLogo(String? logoUrl) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: logoUrl != null && logoUrl.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Icon(
                  Icons.shield_outlined,
                  color: _textSecondary,
                  size: 20,
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.shield_outlined,
                  color: _textSecondary,
                  size: 20,
                ),
              ),
            )
          : Icon(
              Icons.shield_outlined,
              color: _textSecondary,
              size: 20,
            ),
    );
  }

  void _showMatchOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.visibility, color: _primary),
                ),
                title: const Text(
                  '직관 기록하기',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _addToDiary(context, ref);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications, color: Colors.orange),
                ),
                title: const Text(
                  '알림 설정',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showNotificationSettings(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToDiary(BuildContext context, WidgetRef ref) {
    context.push('/diary/add', extra: match);
  }

  void _showNotificationSettings(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _NotificationSettingsDialog(match: match),
    );
  }
}

class _NotificationSettingsDialog extends ConsumerWidget {
  final Match match;

  static const _primary = Color(0xFF2563EB);
  static const _textPrimary = Color(0xFF111827);
  static const _border = Color(0xFFE5E7EB);

  const _NotificationSettingsDialog({required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingAsync = ref.watch(matchNotificationProvider(match.id));

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        '알림 설정',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
      content: settingAsync.when(
        data: (setting) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationTile(
              '킥오프 알림 (30분 전)',
              setting?.notifyKickoff ?? true,
              (value) {
                ref.read(scheduleNotifierProvider.notifier).toggleNotification(
                      matchId: match.id,
                      type: 'kickoff',
                      value: value,
                    );
              },
            ),
            const Divider(height: 1, color: _border),
            _buildNotificationTile(
              '라인업 발표',
              setting?.notifyLineup ?? false,
              (value) {
                ref.read(scheduleNotifierProvider.notifier).toggleNotification(
                      matchId: match.id,
                      type: 'lineup',
                      value: value,
                    );
              },
            ),
            const Divider(height: 1, color: _border),
            _buildNotificationTile(
              '경기 결과',
              setting?.notifyResult ?? true,
              (value) {
                ref.read(scheduleNotifierProvider.notifier).toggleNotification(
                      matchId: match.id,
                      type: 'result',
                      value: value,
                    );
              },
            ),
          ],
        ),
        loading: () => const SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text('오류: $e'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: _primary,
          ),
          child: const Text(
            '닫기',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: _textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _primary,
          ),
        ],
      ),
    );
  }
}

class _ScheduleLiveScoresSection extends ConsumerWidget {
  static const _error = Color(0xFFEF4444);
  static const _textSecondary = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livescoresAsync = ref.watch(scheduleLivescoresProvider);

    return livescoresAsync.when(
      data: (events) {
        final liveEvents = events.where((e) => e.isLive).toList();

        if (liveEvents.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _error.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _error.withValues(alpha: 0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: _error,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: _error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${liveEvents.length}',
                      style: TextStyle(
                        color: _error,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => ref.invalidate(scheduleLivescoresProvider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.refresh, size: 12, color: _textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            '새로고침',
                            style: TextStyle(
                              fontSize: 11,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 65,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: liveEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final event = liveEvents[index];
                    return _ScheduleLiveCard(event: event);
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ScheduleLiveCard extends StatelessWidget {
  final SportsDbLiveEvent event;

  static const _primary = Color(0xFF2563EB);
  static const _error = Color(0xFFEF4444);
  static const _textPrimary = Color(0xFF111827);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE5E7EB);

  const _ScheduleLiveCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/match/${event.id}'),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.league ?? '',
                    style: TextStyle(
                      fontSize: 9,
                      color: _textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: _error,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    event.statusDisplay,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    event.homeTeam ?? '',
                    style: TextStyle(
                      fontSize: 10,
                      color: _textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    event.scoreDisplay,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _primary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    event.awayTeam ?? '',
                    style: TextStyle(
                      fontSize: 10,
                      color: _textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
