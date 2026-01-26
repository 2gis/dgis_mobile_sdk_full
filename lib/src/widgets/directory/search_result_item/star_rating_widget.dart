import 'package:flutter/material.dart';

/// Widget for displaying a star rating with partial fill support.
///
/// This widget renders a row of stars that can be partially filled to
/// represent fractional ratings. For example, a rating of 3.5 will show
/// 3 fully filled stars and 1 half-filled star.
///
/// Usage example:
/// ```dart
/// StarRatingWidget(
///   rating: 4.5,
///   emptyStarColor: Colors.grey,
///   filledStarColor: Colors.amber,
///   starSize: 20,
///   maxRating: 5,
/// )
/// ```
///
/// The widget uses a clipping technique to achieve partial star fills,
/// rendering both an empty star background and a clipped filled star overlay.
class StarRatingWidget extends StatelessWidget {
  /// The rating value to display (typically 0.0 to 5.0).
  final double rating;

  /// Color for unfilled (empty) portions of stars.
  final Color emptyStarColor;

  /// Color for filled portions of stars.
  final Color filledStarColor;

  /// Size of each star in logical pixels.
  final double starSize;

  /// Maximum number of stars to display.
  final int maxRating;

  const StarRatingWidget({
    required this.rating,
    required this.emptyStarColor,
    required this.filledStarColor,
    this.starSize = 16,
    this.maxRating = 5,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, _buildStar),
    );
  }

  Widget _buildStar(int index) {
    final fillValue = (rating - index).clamp(0.0, 1.0);

    return SizedBox(
      width: starSize,
      height: starSize,
      child: Stack(
        children: [
          Icon(
            Icons.star,
            size: starSize,
            color: emptyStarColor,
          ),
          if (fillValue > 0)
            ClipRect(
              clipper: _StarClipper(fillValue),
              child: Icon(
                Icons.star,
                size: starSize,
                color: filledStarColor,
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom clipper for partial star fill rendering.
///
/// Clips the star icon horizontally based on the [fillValue],
/// where 0.0 shows no fill and 1.0 shows full fill.
class _StarClipper extends CustomClipper<Rect> {
  /// The fill percentage (0.0 to 1.0).
  final double fillValue;

  _StarClipper(this.fillValue);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fillValue, size.height);
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) {
    return fillValue != oldClipper.fillValue;
  }
}
