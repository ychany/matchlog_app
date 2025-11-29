import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// 0  i /
class MatchStatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;

  const MatchStatChip({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark
            ? AppColors.surfaceDark
            : AppColors.backgroundLight);
    final fgColor = textColor ??
        (isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark
              ? const Color(0xFF424242)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: fgColor.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
          ],
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: fgColor.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.subtitle2.copyWith(
                  color: fgColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 0  i (/4/()
class MatchResultChip extends StatelessWidget {
  final String result; // 'W', 'D', 'L'
  final double size;

  const MatchResultChip({
    super.key,
    required this.result,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    String text;

    switch (result.toUpperCase()) {
      case 'W':
        bgColor = AppColors.win;
        text = '';
        break;
      case 'D':
        bgColor = AppColors.draw;
        text = '4';
        break;
      case 'L':
        bgColor = AppColors.loss;
        text = '(';
        break;
      default:
        bgColor = AppColors.draw;
        text = '-';
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// 0  i
class ScoreChip extends StatelessWidget {
  final int homeScore;
  final int awayScore;
  final bool isHomeTeam;

  const ScoreChip({
    super.key,
    required this.homeScore,
    required this.awayScore,
    this.isHomeTeam = true,
  });

  @override
  Widget build(BuildContext context) {
    final myScore = isHomeTeam ? homeScore : awayScore;
    final opponentScore = isHomeTeam ? awayScore : homeScore;

    Color bgColor;
    if (myScore > opponentScore) {
      bgColor = AppColors.win;
    } else if (myScore < opponentScore) {
      bgColor = AppColors.loss;
    } else {
      bgColor = AppColors.draw;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: bgColor, width: 1),
      ),
      child: Text(
        '$homeScore - $awayScore',
        style: AppTextStyles.subtitle2.copyWith(
          color: bgColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

///  C i
class LeagueBadgeChip extends StatelessWidget {
  final String league;

  const LeagueBadgeChip({
    super.key,
    required this.league,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getLeagueColor(league).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        league,
        style: AppTextStyles.caption.copyWith(
          color: _getLeagueColor(league),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getLeagueColor(String league) {
    switch (league.toUpperCase()) {
      case 'EPL':
        return AppColors.premierLeague;
      case 'LA LIGA':
        return AppColors.laLiga;
      case 'SERIE A':
        return AppColors.serieA;
      case 'BUNDESLIGA':
        return AppColors.bundesliga;
      case 'LIGUE 1':
        return AppColors.ligue1;
      case 'K-LEAGUE':
        return AppColors.kleague;
      case 'UCL':
      case 'UEL':
        return AppColors.ucl;
      default:
        return AppColors.primary;
    }
  }
}
