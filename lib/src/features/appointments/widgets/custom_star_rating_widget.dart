import 'package:flutter/material.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../theme/app_colors.dart';

class CustomStarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool isInteractive;
  final Function(double)? onRatingUpdate;

  const CustomStarRating({
    super.key,
    required this.rating,
    this.size = 30,
    this.isInteractive = true,
    this.onRatingUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: isInteractive
              ? () => onRatingUpdate?.call((index + 1).toDouble())
              : null,
          child: Container(
            padding: const EdgeInsets.all(2),
            child: Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: size,
            ),
          ),
        );
      }),
    );
  }
} 