import 'package:flutter/material.dart';

import '../data/models.dart';

/// Rounded square photo of [food], falling back to its tinted icon when no
/// bundled image exists (e.g. barcode-catalog products).
class FoodImage extends StatelessWidget {
  const FoodImage({
    super.key,
    required this.food,
    required this.size,
    required this.radius,
    required this.bg,
    required this.fg,
  });

  final FoodItem food;
  final double size;
  final double radius;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        color: bg,
        child: Image.asset(
          food.imageAsset,
          fit: BoxFit.cover,
          cacheWidth: (size * dpr).round(),
          errorBuilder: (context, _, __) =>
              Icon(food.icon, color: fg, size: size * 0.5),
        ),
      ),
    );
  }
}
