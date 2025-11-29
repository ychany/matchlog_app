import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../core/theme/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool showLabel;
  final Color? activeColor;
  final Color? inactiveColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.showLabel = false,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) => Icon(
            Icons.star_rounded,
            color: activeColor ?? AppColors.warning,
          ),
          unratedColor: inactiveColor ?? Colors.grey.shade300,
          itemCount: 5,
          itemSize: size,
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.7,
              fontWeight: FontWeight.w600,
              color: activeColor ?? AppColors.warning,
            ),
          ),
        ],
      ],
    );
  }
}

class RatingStarsInput extends StatelessWidget {
  final double initialRating;
  final ValueChanged<double> onRatingUpdate;
  final double size;
  final bool allowHalfRating;

  const RatingStarsInput({
    super.key,
    this.initialRating = 3,
    required this.onRatingUpdate,
    this.size = 32,
    this.allowHalfRating = false,
  });

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: initialRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: allowHalfRating,
      itemCount: 5,
      itemSize: size,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2),
      itemBuilder: (context, _) => const Icon(
        Icons.star_rounded,
        color: AppColors.warning,
      ),
      unratedColor: Colors.grey.shade300,
      onRatingUpdate: onRatingUpdate,
    );
  }
}

// Compact rating display
class RatingBadge extends StatelessWidget {
  final double rating;
  final double size;

  const RatingBadge({
    super.key,
    required this.rating,
    this.size = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            color: AppColors.warning,
            size: size,
          ),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.9,
              fontWeight: FontWeight.w600,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
