import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// 0  | /
class StadiumInfoTile extends StatelessWidget {
  final String stadiumName;
  final String? address;
  final String? capacity;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onDirectionsTap;

  const StadiumInfoTile({
    super.key,
    required this.stadiumName,
    this.address,
    this.capacity,
    this.imageUrl,
    this.onTap,
    this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Stadium Icon or Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.stadium,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.stadium,
                        color: AppColors.primary,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 12),

              // Stadium Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stadiumName,
                      style: AppTextStyles.subtitle1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address!,
                              style: AppTextStyles.caption.copyWith(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (capacity != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'x: $capacity',
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

              // Directions Button
              if (onDirectionsTap != null)
                IconButton(
                  onPressed: onDirectionsTap,
                  icon: const Icon(
                    Icons.directions,
                    color: AppColors.primary,
                  ),
                  tooltip: '8>0',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ) 0  |
class StadiumInfoTileCompact extends StatelessWidget {
  final String stadiumName;
  final String? location;
  final VoidCallback? onTap;

  const StadiumInfoTileCompact({
    super.key,
    required this.stadiumName,
    this.location,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.stadium_outlined,
              size: 18,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stadiumName,
                    style: AppTextStyles.body2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (location != null)
                    Text(
                      location!,
                      style: AppTextStyles.caption.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}

/// 0    Dt\
class StadiumSelectTile extends StatelessWidget {
  final String stadiumName;
  final String? league;
  final String? teamName;
  final bool isSelected;
  final VoidCallback? onTap;

  const StadiumSelectTile({
    super.key,
    required this.stadiumName,
    this.league,
    this.teamName,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(
          Icons.stadium,
          color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
        ),
      ),
      title: Text(
        stadiumName,
        style: AppTextStyles.subtitle2.copyWith(
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      subtitle: teamName != null || league != null
          ? Text(
              [teamName, league].where((e) => e != null).join('  '),
              style: AppTextStyles.caption,
            )
          : null,
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: AppColors.primary,
            )
          : null,
    );
  }
}
