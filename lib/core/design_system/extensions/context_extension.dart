import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../tokens/tokens.dart';

extension ContextExtension on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;

  ColorTokens get colors => appTheme.colors;

  SpaceExtension get space => SpaceExtension(this);

  RadiusExtension get radius => RadiusExtension(this);

  TypographyExtension get typo => TypographyExtension(this);

  DimensionExtension get dimensions => DimensionExtension(this);
}

// spacing wrapper
class SpaceExtension {
  final BuildContext context;

  SpaceExtension(this.context);

  double get sm => context.appTheme.spacing.sm(context);

  double get md => context.appTheme.spacing.md(context);

  double get lg => context.appTheme.spacing.lg(context);
}

// radius wrapper
class RadiusExtension {
  final BuildContext context;

  RadiusExtension(this.context);

  double get md => context.appTheme.radius.md(context);
}

// typography wrapper
class TypographyExtension {
  final BuildContext context;

  TypographyExtension(this.context);

  TextStyle get title => context.appTheme.typography.title(context);

  TextStyle get body => context.appTheme.typography.body(context);
}

// dimension wrapper
class DimensionExtension {
  final BuildContext context;

  DimensionExtension(this.context);

  double get buttonHeight => context.appTheme.dimensions.buttonHeight(context);

  double get icon => context.appTheme.dimensions.icon(context);

  double get avatar => context.appTheme.dimensions.avatar(context);

  double get imageWidth => context.appTheme.dimensions.imageWidth(context);

  double get imageHeight => context.appTheme.dimensions.imageHeight(context);
}
