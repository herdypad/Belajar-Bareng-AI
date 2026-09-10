import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: AppColors.darkBg,
        card: AppColors.darkCard,
        border: AppColors.darkBorder,
        onBg: Colors.white,
        muted: const Color(0xFF9A93B5),
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: AppColors.lightBg,
        card: AppColors.lightCard,
        border: AppColors.lightBorder,
        onBg: const Color(0xFF1A1530),
        muted: const Color(0xFF6B6685),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color card,
    required Color border,
    required Color onBg,
    required Color muted,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: AppColors.primary,
      surface: card,
      onSurface: onBg,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: scheme,
      cardColor: card,
      dividerColor: border,
      fontFamily: 'Roboto',
      textTheme: Typography.material2021(platform: TargetPlatform.android)
          .black
          .apply(bodyColor: onBg, displayColor: onBg)
          .let(brightness == Brightness.dark, onBg),
      extensions: <ThemeExtension<dynamic>>[
        AppSurfaces(
          card: card,
          border: border,
          muted: muted,
          input: brightness == Brightness.dark
              ? AppColors.darkInput
              : AppColors.lightInput,
          accent: brightness == Brightness.dark
              ? AppColors.lilac
              : AppColors.primary,
        ),
      ],
    );
  }
}

/// Helper agar text theme mengikuti warna pada dark mode.
extension _ApplyColor on TextTheme {
  TextTheme let(bool isDark, Color color) =>
      isDark ? apply(bodyColor: color, displayColor: color) : this;
}

/// Warna surface kustom yang dipakai di seluruh layar (meniru CSS variables mockup).
class AppSurfaces extends ThemeExtension<AppSurfaces> {
  final Color card;
  final Color border;
  final Color muted;
  final Color input;
  final Color accent;

  const AppSurfaces({
    required this.card,
    required this.border,
    required this.muted,
    required this.input,
    required this.accent,
  });

  @override
  AppSurfaces copyWith({
    Color? card,
    Color? border,
    Color? muted,
    Color? input,
    Color? accent,
  }) =>
      AppSurfaces(
        card: card ?? this.card,
        border: border ?? this.border,
        muted: muted ?? this.muted,
        input: input ?? this.input,
        accent: accent ?? this.accent,
      );

  @override
  AppSurfaces lerp(ThemeExtension<AppSurfaces>? other, double t) {
    if (other is! AppSurfaces) return this;
    return AppSurfaces(
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      input: Color.lerp(input, other.input, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

extension AppSurfacesContext on BuildContext {
  AppSurfaces get surfaces => Theme.of(this).extension<AppSurfaces>()!;
}
