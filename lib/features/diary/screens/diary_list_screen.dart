import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/rating_stars.dart';
import '../../../shared/widgets/team_logo.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';

class DiaryListScreen extends ConsumerWidget {
  const DiaryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diaryAsync = ref.watch(diaryListProvider);
    final summaryAsync = ref.watch(currentYearSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('경기 다이어리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => _showYearlySummary(context, summaryAsync),
          ),
        ],
      ),
      body: diaryAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return EmptyDiaryState(
              onAdd: () => context.go('/schedule'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(diaryListProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                return _DiaryCard(
                  entry: entries[index],
                  onTap: () => context.push('/diary/${entries[index].id}'),
                );
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(diaryListProvider),
        ),
      ),
    );
  }

  void _showYearlySummary(BuildContext context, AsyncValue<DiarySummary> summaryAsync) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => _SummarySheet(
          summaryAsync: summaryAsync,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

class _DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback? onTap;

  const _DiaryCard({
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date & League
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('yyyy.MM.dd').format(entry.matchDate),
                    style: AppTextStyles.caption.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.league,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Teams & Score
              Row(
                children: [
                  TeamLogo(
                    logoUrl: entry.homeTeamLogo,
                    teamName: entry.homeTeamName,
                    size: 36,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          '${entry.homeTeamName} vs ${entry.awayTeamName}',
                          style: AppTextStyles.subtitle2,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.scoreDisplay,
                          style: AppTextStyles.headline3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  TeamLogo(
                    logoUrl: entry.awayTeamLogo,
                    teamName: entry.awayTeamName,
                    size: 36,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Rating & Favorite Player
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RatingStars(
                    rating: entry.rating.toDouble(),
                    size: 18,
                  ),
                  if (entry.favoritePlayerName != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          entry.favoritePlayerName!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              // Memo preview
              if (entry.memo != null && entry.memo!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.memo!,
                  style: AppTextStyles.caption.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummarySheet extends StatelessWidget {
  final AsyncValue<DiarySummary> summaryAsync;
  final ScrollController scrollController;

  const _SummarySheet({
    required this.summaryAsync,
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
          summaryAsync.when(
            data: (summary) => Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  Text(
                    '${summary.year}년 요약',
                    style: AppTextStyles.headline2,
                  ),
                  const SizedBox(height: 24),
                  _SummaryStatCard(
                    icon: Icons.visibility,
                    label: '총 관람 경기',
                    value: '${summary.totalMatches}',
                  ),
                  const SizedBox(height: 12),
                  _SummaryStatCard(
                    icon: Icons.star,
                    label: '평균 평점',
                    value: summary.averageRating.toStringAsFixed(1),
                  ),
                  if (summary.favoriteTeamName != null) ...[
                    const SizedBox(height: 12),
                    _SummaryStatCard(
                      icon: Icons.favorite,
                      label: '가장 많이 본 팀',
                      value: summary.favoriteTeamName!,
                      subtitle: '${summary.favoriteTeamWatched}경기',
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    '리그별 통계',
                    style: AppTextStyles.subtitle1,
                  ),
                  const SizedBox(height: 12),
                  ...summary.leagueCount.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: AppTextStyles.body2),
                        Text(
                          '${entry.value}경기',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            loading: () => const Expanded(child: LoadingIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _SummaryStatCard({
    required this.icon,
    required this.label,
    required this.value,
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
              Text(label, style: AppTextStyles.caption),
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
