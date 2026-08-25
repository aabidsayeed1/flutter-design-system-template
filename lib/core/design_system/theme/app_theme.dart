import 'package:flutter/material.dart';

import '../responsive/responsive_value.dart';
import '../tokens/tokens.dart';
import 'app_theme_extension.dart';

class AppTheme {
  static const SpacingTokens spacing = SpacingTokens();
  static const RadiusTokens radius = RadiusTokens();
  static const TypographyTokens typography = TypographyTokens();
  static const DimensionTokens dimensions = DimensionTokens();
  static const ElevationTokens elevations = ElevationTokens();

  static const Size mobileDesignSize = Size(390, 844);
  static const Size tabletDesignSize = Size(834, 1194);
  static const Size desktopDesignSize = Size(1440, 1024);

  static final ThemeData light = _buildTheme(
    colors: const LightColorTokens(),
    gradients: const LightGradientTokens(),
    shadows: const LightShadowTokens(),
    brightness: Brightness.light,
  );

  static final ThemeData dark = _buildTheme(
    colors: const DarkColorTokens(),
    gradients: const DarkGradientTokens(),
    shadows: const DarkShadowTokens(),
    brightness: Brightness.dark,
  );

  static final ThemeData aurora = _buildTheme(
    colors: const AuroraColorTokens(),
    gradients: const AuroraGradientTokens(),
    shadows: const AuroraShadowTokens(),
    brightness: Brightness.light,
  );

  static final Map<String, ThemeData> themes = {
    'light': light,
    'dark': dark,
    'aurora': aurora,
  };

  static ThemeData theme(String themeName) => themes[themeName] ?? themes.values.first;

  static Size designSize(BuildContext context) {
    return ResponsiveValue<Size>(
      mobile: mobileDesignSize,
      tablet: tabletDesignSize,
      desktop: desktopDesignSize,
    ).resolve(context);
  }

  static ThemeData _buildTheme({
    required ColorTokensBase colors,
    required GradientTokensBase gradients,
    required ShadowTokensBase shadows,
    required Brightness brightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: brightness == Brightness.dark
          ? ColorScheme.dark(
              primary: colors.primary,
              surface: colors.surface,
              error: colors.error,
            )
          : ColorScheme.light(
              primary: colors.primary,
              surface: colors.surface,
              error: colors.error,
            ),
      extensions: [
        AppThemeExtension(
          colors: colors,
          gradients: gradients,
          shadows: shadows,
          spacing: spacing,
          radius: radius,
          typography: typography,
          dimensions: dimensions,
          elevations: elevations,
        ),
      ],
    );
  }
}
