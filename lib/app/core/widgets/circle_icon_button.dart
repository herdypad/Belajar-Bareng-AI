import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tombol ikon bulat (back, settings, flag) seperti pada mockup.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? background;
  final Color? foreground;
  final Color? borderColor;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.background,
    this.foreground,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.surfaces;
    return Material(
      color: background ?? s.card,
      shape: CircleBorder(side: BorderSide(color: borderColor ?? s.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 20, color: foreground),
        ),
      ),
    );
  }
}
