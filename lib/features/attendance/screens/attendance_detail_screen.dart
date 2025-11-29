import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/photo_carousel.dart';
import '../../../shared/widgets/team_logo.dart';
import '../models/attendance_record.dart';
import '../providers/attendance_provider.dart';

class AttendanceDetailScreen extends ConsumerWidget {
  final String recordId;

  const AttendanceDetailScreen({
    super.key,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(attendanceDetailProvider(recordId));

    return Scaffold(
      body: recordAsync.when(
        data: (record) {
          if (record == null) {
            return const Center(child: Text('기록을 찾을 수 없습니다'));
          }
          return _DetailContent(record: record);
        },
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final AttendanceRecord record;

  const _DetailContent({required this.record});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // App Bar with gradient
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Teams Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            TeamLogo(
                              logoUrl: record.homeTeamLogo,
                              teamName: record.homeTeamName,
                              size: 56,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              record.homeTeamName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            record.scoreDisplay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            TeamLogo(
                              logoUrl: record.awayTeamLogo,
                              teamName: record.awayTeamName,
                              size: 56,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              record.awayTeamName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Rating & Mood indicator
                    if (record.rating != null || record.mood != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (record.rating != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    record.rating!.toStringAsFixed(1),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (record.rating != null && record.mood != null)
                            const SizedBox(width: 8),
                          if (record.mood != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${record.mood!.emoji} ${record.mood!.label}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                record.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: record.isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () {
                // TODO: Toggle favorite
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/attendance/${record.id}/edit');
              },
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos
              if (record.photos.isNotEmpty) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PhotoCarousel(
                    photos: record.photos,
                    height: 220,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Diary Title (한 줄 요약)
              if (record.diaryTitle != null && record.diaryTitle!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.format_quote, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            record.diaryTitle!,
                            style: AppTextStyles.subtitle1.copyWith(
                              color: AppColors.primary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // MVP Section
              if (record.mvpPlayerName != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildMvpCard(),
                ),
                const SizedBox(height: 24),
              ],

              // Tags
              if (record.tags.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: record.tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '#$tag',
                        style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Diary Content
              if (record.diaryContent != null && record.diaryContent!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('직관 일기', style: AppTextStyles.subtitle1),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          record.diaryContent!,
                          style: AppTextStyles.body1.copyWith(height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Match Info Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sports_soccer, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('경기 정보', style: AppTextStyles.subtitle1),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.calendar_today,
                      label: '날짜',
                      value: DateFormat('yyyy.MM.dd (EEEE)', 'ko').format(record.date),
                    ),
                    _InfoTile(
                      icon: Icons.emoji_events,
                      label: '리그',
                      value: record.league,
                    ),
                    _InfoTile(
                      icon: Icons.stadium,
                      label: '경기장',
                      value: record.stadium,
                    ),
                    if (record.seatInfo != null)
                      _InfoTile(
                        icon: Icons.chair,
                        label: '좌석',
                        value: record.seatInfo!,
                      ),
                  ],
                ),
              ),

              // Additional Info Section
              if (_hasAdditionalInfo()) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('추가 정보', style: AppTextStyles.subtitle1),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (record.weather != null)
                        _InfoTile(icon: Icons.cloud, label: '날씨', value: record.weather!),
                      if (record.companion != null)
                        _InfoTile(icon: Icons.people, label: '함께 간 사람', value: record.companion!),
                      if (record.ticketPrice != null)
                        _InfoTile(icon: Icons.confirmation_number, label: '티켓 가격', value: '${NumberFormat('#,###').format(record.ticketPrice)}원'),
                    ],
                  ),
                ),
              ],

              // Food Review
              if (record.foodReview != null && record.foodReview!.isNotEmpty) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.restaurant, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('경기장 음식', style: AppTextStyles.subtitle1),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          record.foodReview!,
                          style: AppTextStyles.body2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Old Memo (for backwards compatibility)
              if (record.memo != null && record.memo!.isNotEmpty && (record.diaryContent == null || record.diaryContent!.isEmpty)) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('메모', style: AppTextStyles.subtitle1),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(record.memo!, style: AppTextStyles.body2),
                      ),
                    ],
                  ),
                ),
              ],

              // Location
              if (record.latitude != null && record.longitude != null) ...[
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('위치', style: AppTextStyles.subtitle1),
                      const SizedBox(height: 12),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Center(
                          child: Icon(Icons.map, size: 48, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  bool _hasAdditionalInfo() {
    return record.weather != null || record.companion != null || record.ticketPrice != null;
  }

  Widget _buildMvpCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade100, Colors.amber.shade50],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.emoji_events, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오늘의 MVP', style: AppTextStyles.caption.copyWith(color: Colors.amber.shade800)),
                const SizedBox(height: 4),
                Text(
                  record.mvpPlayerName!,
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.body2),
          ),
        ],
      ),
    );
  }
}
