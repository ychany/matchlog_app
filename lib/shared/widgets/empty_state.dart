import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.stadium_outlined,
      title: l10n.emptyAttendanceTitle,
      subtitle: l10n.emptyAttendanceSubtitle,
      actionLabel: l10n.addRecord,
      onAction: onAdd,
    );
  }
}

class EmptyDiaryState extends StatelessWidget {
  final VoidCallback? onAdd;

  const EmptyDiaryState({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.book_outlined,
      title: l10n.emptyDiaryTitle,
      subtitle: l10n.emptyDiarySubtitle,
      actionLabel: l10n.viewSchedule,
      onAction: onAdd,
    );
  }
}

class EmptyScheduleState extends StatelessWidget {
  const EmptyScheduleState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: l10n.emptyScheduleTitle,
      subtitle: l10n.emptyScheduleSubtitle,
    );
  }
}

class EmptyFavoritesState extends StatelessWidget {
  final VoidCallback? onAdd;

  const EmptyFavoritesState({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.favorite_border,
      title: l10n.emptyFavoritesTitle,
      subtitle: l10n.emptyFavoritesSubtitle,
      actionLabel: l10n.findTeam,
      onAction: onAdd,
    );
  }
}

class EmptySearchState extends StatelessWidget {
  final String query;

  const EmptySearchState({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.search_off,
      title: l10n.emptySearchTitle,
      subtitle: l10n.emptySearchSubtitle(query),
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
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Icons.error_outline,
      title: l10n.errorTitle,
      subtitle: message ?? l10n.errorDefaultSubtitle,
      actionLabel: l10n.retry,
      onAction: onRetry,
    );
  }
}
