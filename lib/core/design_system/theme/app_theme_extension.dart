import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final ColorTokens colors;
  final SpacingTokens spacing;
  final RadiusTokens radius;
  final TypographyTokens typography;
  final DimensionTokens dimensions;

  const AppThemeExtension({
    required this.colors,
    required this.spacing,
    required this.radius,
    required this.typography,
    required this.dimensions,
  });

  @override
  AppThemeExtension copyWith({
    ColorTokens? colors,
    SpacingTokens? spacing,
    RadiusTokens? radius,
    TypographyTokens? typography,
    DimensionTokens? dimensions,
  }) {
    return AppThemeExtension(
      colors: colors ?? this.colors,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      typography: typography ?? this.typography,
      dimensions: dimensions ?? this.dimensions,
    );
  }

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    return this;
  }
}
