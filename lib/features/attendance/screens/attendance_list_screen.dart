import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/team_logo.dart';
import '../models/attendance_record.dart';
import '../providers/attendance_provider.dart';

class AttendanceListScreen extends ConsumerWidget {
  const AttendanceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(attendanceListProvider);
    final statsAsync = ref.watch(attendanceStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 직관 일기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _showStatsBottomSheet(context, statsAsync),
          ),
        ],
      ),
      body: attendanceAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return EmptyAttendanceState(
              onAdd: () => _navigateToAdd(context),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(attendanceListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: records.length,
              itemBuilder: (context, index) {
                return _AttendanceCard(
                  record: records[index],
                  onTap: () => _navigateToDetail(context, records[index].id),
                  onLongPress: () => _showOptions(context, ref, records[index]),
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(attendanceListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('직관 기록'),
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    context.push('/attendance/add');
  }

  void _navigateToDetail(BuildContext context, String id) {
    context.push('/attendance/$id');
  }

  void _showOptions(BuildContext context, WidgetRef ref, AttendanceRecord record) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('수정'),
              onTap: () {
                Navigator.pop(context);
                context.push('/attendance/${record.id}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('삭제', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, record.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: const Text('이 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(attendanceNotifierProvider.notifier).deleteAttendance(id);
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showStatsBottomSheet(BuildContext context, AsyncValue<AttendanceStats> statsAsync) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _StatsSheet(
          statsAsync: statsAsync,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _AttendanceCard({
    required this.record,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date, League & Mood/Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            DateFormat('yyyy.MM.dd (E)', 'ko').format(record.date),
                            style: AppTextStyles.caption.copyWith(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (record.mood != null) ...[
                          const SizedBox(width: 8),
                          Text(record.mood!.emoji, style: const TextStyle(fontSize: 14)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (record.rating != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text(
                                record.rating!.toStringAsFixed(1),
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      _LeagueBadge(league: record.league),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Teams & Score
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        TeamLogo(
                          logoUrl: record.homeTeamLogo,
                          teamName: record.homeTeamName,
                          size: 40,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            record.homeTeamName,
                            style: AppTextStyles.subtitle2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      record.scoreDisplay,
                      style: AppTextStyles.headline3,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            record.awayTeamName,
                            style: AppTextStyles.subtitle2,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        TeamLogo(
                          logoUrl: record.awayTeamLogo,
                          teamName: record.awayTeamName,
                          size: 40,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Diary Title Preview
              if (record.diaryTitle != null && record.diaryTitle!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.format_quote, size: 16, color: AppColors.primary.withValues(alpha: 0.6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          record.diaryTitle!,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Stadium, Photos & Tags indicator
              Row(
                children: [
                  Icon(
                    Icons.stadium_outlined,
                    size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      record.stadium,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (record.photos.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.photo_library_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${record.photos.length}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                  if (record.diaryContent != null && record.diaryContent!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.menu_book,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                  ],
                  if (record.mvpPlayerName != null) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.emoji_events,
                      size: 14,
                      color: Colors.amber,
                    ),
                  ],
                ],
              ),

              // Tags Preview
              if (record.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: record.tags.take(4).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '#$tag',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondary,
                        fontSize: 11,
                      ),
                    ),
                  )).toList(),
                ),
              ],

              if (record.seatInfo != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.chair_outlined,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      record.seatInfo!,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LeagueBadge extends StatelessWidget {
  final String league;

  const _LeagueBadge({required this.league});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        league,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatsSheet extends StatelessWidget {
  final AsyncValue<AttendanceStats> statsAsync;
  final ScrollController scrollController;

  const _StatsSheet({
    required this.statsAsync,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            '직관 통계',
            style: AppTextStyles.headline3,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: statsAsync.when(
              data: (stats) => ListView(
                controller: scrollController,
                children: [
                  _StatCard(
                    title: '총 경기 수',
                    value: '${stats.totalMatches}',
                    icon: Icons.stadium,
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: '승률',
                    value: '${stats.winRate.toStringAsFixed(1)}%',
                    icon: Icons.emoji_events,
                    subtitle: '${stats.wins}승 ${stats.draws}무 ${stats.losses}패',
                  ),
                  const SizedBox(height: 12),
                  _StatCard(
                    title: '방문한 경기장',
                    value: '${stats.stadiumVisits.length}',
                    icon: Icons.place,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '리그별 통계',
                    style: AppTextStyles.subtitle1,
                  ),
                  const SizedBox(height: 8),
                  ...stats.leagueCount.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text('${entry.value}경기'),
                      ],
                    ),
                  )),
                ],
              ),
              loading: () => const LoadingIndicator(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.headline3),
              if (subtitle != null)
                Text(subtitle!, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
