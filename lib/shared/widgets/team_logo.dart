import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';

class TeamLogo extends StatelessWidget {
  final String? logoUrl;
  final String teamName;
  final double size;
  final bool showBorder;

  const TeamLogo({
    super.key,
    this.logoUrl,
    required this.teamName,
    this.size = 40,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: isDark ? Colors.white24 : Colors.black12,
                width: 1,
              )
            : null,
      ),
      child: ClipOval(
        child: logoUrl != null && logoUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: logoUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildPlaceholder(isDark),
                errorWidget: (context, url, error) => _buildPlaceholder(isDark),
              )
            : _buildPlaceholder(isDark),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
      child: Center(
        child: Text(
          _getInitials(teamName),
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.bold,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : name.length).toUpperCase();
  }
}

// Team badge with name
class TeamBadge extends StatelessWidget {
  final String? logoUrl;
  final String teamName;
  final double size;
  final bool showName;
  final VoidCallback? onTap;

  const TeamBadge({
    super.key,
    this.logoUrl,
    required this.teamName,
    this.size = 40,
    this.showName = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TeamLogo(
            logoUrl: logoUrl,
            teamName: teamName,
            size: size,
          ),
          if (showName) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: size + 20,
              child: Text(
                teamName,
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Horizontal team row (logo + name)
class TeamRow extends StatelessWidget {
  final String? logoUrl;
  final String teamName;
  final double logoSize;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TeamRow({
    super.key,
    this.logoUrl,
    required this.teamName,
    this.logoSize = 32,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            TeamLogo(
              logoUrl: logoUrl,
              teamName: teamName,
              size: logoSize,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                teamName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
