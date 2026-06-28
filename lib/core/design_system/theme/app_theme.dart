import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import 'app_theme_extension.dart';

class AppTheme {
  static const colors = ColorTokens();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: colors.background,
    colorScheme: ColorScheme.light(
      primary: colors.primary,
      surface: colors.surface,
    ),
    extensions: [
      AppThemeExtension(
        colors: colors,
        spacing: const SpacingTokens(),
        radius: const RadiusTokens(),
        typography: const TypographyTokens(),
        dimensions: const DimensionTokens(),
      )
    ],
  );
}
