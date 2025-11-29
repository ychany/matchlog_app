import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.headline3.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.body2.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyAttendanceState extends StatelessWidget {
  final VoidCallback? onAdd;

  const EmptyAttendanceState({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.stadium_outlined,
      title: '직관 기록이 없습니다',
      subtitle: '첫 번째 경기 직관을 기록해보세요!',
      actionLabel: '기록 추가',
      onAction: onAdd,
    );
  }
}

class EmptyDiaryState extends StatelessWidget {
  final VoidCallback? onAdd;

  const EmptyDiaryState({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.book_outlined,
      title: '다이어리 기록이 없습니다',
      subtitle: '경기를 보고 기록해보세요!',
      actionLabel: '일정 보기',
      onAction: onAdd,
    );
  }
}

class EmptyScheduleState extends StatelessWidget {
  const EmptyScheduleState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.calendar_today_outlined,
      title: '오늘 경기가 없습니다',
      subtitle: '다른 날짜를 선택해보세요',
    );
  }
}

class EmptyFavoritesState extends StatelessWidget {
  final VoidCallback? onAdd;

  const EmptyFavoritesState({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.favorite_border,
      title: '즐겨찾기가 없습니다',
      subtitle: '좋아하는 팀과 선수를 추가해보세요!',
      actionLabel: '팀 찾기',
      onAction: onAdd,
    );
  }
}

class EmptySearchState extends StatelessWidget {
  final String query;

  const EmptySearchState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: '검색 결과가 없습니다',
      subtitle: '"$query"에 대한 결과가 없습니다',
    );
  }
}

class ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: '오류가 발생했습니다',
      subtitle: message ?? '다시 시도해주세요',
      actionLabel: '재시도',
      onAction: onRetry,
    );
  }
}
