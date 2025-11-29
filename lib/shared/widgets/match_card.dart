import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../models/match_model.dart';
import 'team_logo.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showNotificationIcon;
  final bool isNotificationEnabled;
  final VoidCallback? onNotificationToggle;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.onLongPress,
    this.showNotificationIcon = false,
    this.isNotificationEnabled = false,
    this.onNotificationToggle,
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
            children: [
              // League & Time Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _LeagueBadge(league: match.league),
                  Row(
                    children: [
                      Text(
                        _formatKickoff(match.kickoff),
                        style: AppTextStyles.caption.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (showNotificationIcon) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onNotificationToggle,
                          child: Icon(
                            isNotificationEnabled
                                ? Icons.notifications_active
                                : Icons.notifications_none,
                            size: 20,
                            color: isNotificationEnabled
                                ? AppColors.primary
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Teams & Score Row
              Row(
                children: [
                  // Home Team
                  Expanded(
                    child: _TeamColumn(
                      teamName: match.homeTeamName,
                      logoUrl: match.homeTeamLogo,
                      isHome: true,
                    ),
                  ),

                  // Score
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ScoreDisplay(match: match),
                  ),

                  // Away Team
                  Expanded(
                    child: _TeamColumn(
                      teamName: match.awayTeamName,
                      logoUrl: match.awayTeamLogo,
                      isHome: false,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stadium & Broadcast
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.stadium_outlined,
                    size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      match.stadium,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (match.broadcast != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.tv,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      match.broadcast!,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),

              // Live indicator
              if (match.isLive)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatKickoff(DateTime kickoff) {
    final now = DateTime.now();
    final isToday = kickoff.day == now.day &&
        kickoff.month == now.month &&
        kickoff.year == now.year;

    if (isToday) {
      return DateFormat('HH:mm').format(kickoff);
    }
    return DateFormat('MM/dd HH:mm').format(kickoff);
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

class _TeamColumn extends StatelessWidget {
  final String teamName;
  final String? logoUrl;
  final bool isHome;

  const _TeamColumn({
    required this.teamName,
    this.logoUrl,
    required this.isHome,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TeamLogo(
          logoUrl: logoUrl,
          teamName: teamName,
          size: 48,
        ),
        const SizedBox(height: 8),
        Text(
          teamName,
          style: AppTextStyles.subtitle2,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ScoreDisplay extends StatelessWidget {
  final Match match;

  const _ScoreDisplay({required this.match});

  @override
  Widget build(BuildContext context) {
    if (match.isFinished || match.isLive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${match.homeScore ?? 0}',
            style: AppTextStyles.matchScore,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '-',
              style: AppTextStyles.matchScore.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          Text(
            '${match.awayScore ?? 0}',
            style: AppTextStyles.matchScore,
          ),
        ],
      );
    }

    return Text(
      'vs',
      style: AppTextStyles.headline3.copyWith(
        color: AppColors.textSecondaryLight,
      ),
    );
  }
}

// Compact version for lists
class MatchCardCompact extends StatelessWidget {
  final Match match;
  final VoidCallback? onTap;

  const MatchCardCompact({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: _LeagueBadge(league: match.league),
      title: Text(
        '${match.homeTeamName} vs ${match.awayTeamName}',
        style: AppTextStyles.subtitle2,
      ),
      subtitle: Text(
        DateFormat('MM/dd HH:mm').format(match.kickoff),
        style: AppTextStyles.caption,
      ),
      trailing: match.isFinished
          ? Text(
              match.scoreDisplay,
              style: AppTextStyles.subtitle1,
            )
          : const Icon(Icons.chevron_right),
    );
  }
}
