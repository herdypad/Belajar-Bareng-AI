import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Kartu dengan sudut membulat & border, meniru komponen Card pada mockup.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.onTap,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.surfaces;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? s.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? s.border),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: card,
    );
  }
}
