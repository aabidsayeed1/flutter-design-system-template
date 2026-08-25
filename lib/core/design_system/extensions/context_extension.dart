import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../tokens/color_tokens.dart';

extension ContextExtension on BuildContext {
  AppThemeExtension get appTheme => Theme.of(this).extension<AppThemeExtension>()!;

  ColorTokensBase get colors => appTheme.colors;

  GradientExtension get gradients => GradientExtension(this);

  ShadowExtension get shadows => ShadowExtension(this);

  SpaceExtension get space => SpaceExtension(this);

  RadiusExtension get radius => RadiusExtension(this);

  TypographyExtension get typo => TypographyExtension(this);

  DimensionExtension get dimensions => DimensionExtension(this);

  ElevationExtension get elevation => ElevationExtension(this);
}

class GradientExtension {
  final BuildContext context;

  GradientExtension(this.context);

  Gradient get brandLinear => context.appTheme.gradients.brandLinear(context);

  Gradient get surfaceRadial => context.appTheme.gradients.surfaceRadial(context);

  Gradient get statusSweep => context.appTheme.gradients.statusSweep(context);

}

class ShadowExtension {
  final BuildContext context;

  ShadowExtension(this.context);

  List<BoxShadow> get card => context.appTheme.shadows.card(context);

  List<BoxShadow> get floating => context.appTheme.shadows.floating(context);

}

class SpaceExtension {
  final BuildContext context;

  SpaceExtension(this.context);

  double get lg => context.appTheme.spacing.lg(context);

  double get md => context.appTheme.spacing.md(context);

  double get sm => context.appTheme.spacing.sm(context);

  double get x2xl => context.appTheme.spacing.x2xl(context);

  double get xl => context.appTheme.spacing.xl(context);

  double get xs => context.appTheme.spacing.xs(context);

}

class RadiusExtension {
  final BuildContext context;

  RadiusExtension(this.context);

  double get full => context.appTheme.radius.full(context);

  double get lg => context.appTheme.radius.lg(context);

  double get md => context.appTheme.radius.md(context);

  double get sm => context.appTheme.radius.sm(context);

  double get xl => context.appTheme.radius.xl(context);

  double get xs => context.appTheme.radius.xs(context);

}

class TypographyExtension {
  final BuildContext context;

  TypographyExtension(this.context);

  TextStyle get body => context.appTheme.typography.body(context);

  TextStyle get bodyLarge => context.appTheme.typography.bodyLarge(context);

  TextStyle get bodySmall => context.appTheme.typography.bodySmall(context);

  TextStyle get button => context.appTheme.typography.button(context);

  TextStyle get caption => context.appTheme.typography.caption(context);

  TextStyle get display => context.appTheme.typography.display(context);

  TextStyle get h1 => context.appTheme.typography.h1(context);

  TextStyle get h2 => context.appTheme.typography.h2(context);

  TextStyle get h3 => context.appTheme.typography.h3(context);

  TextStyle get label => context.appTheme.typography.label(context);

  TextStyle get number => context.appTheme.typography.number(context);

  TextStyle get numberSmall => context.appTheme.typography.numberSmall(context);

  TextStyle get overline => context.appTheme.typography.overline(context);

  TextStyle get subtitle => context.appTheme.typography.subtitle(context);

  TextStyle get title => context.appTheme.typography.title(context);

}

class DimensionExtension {
  final BuildContext context;

  DimensionExtension(this.context);

  double get avatar => context.appTheme.dimensions.avatar(context);

  double get bottomNavHeight => context.appTheme.dimensions.bottomNavHeight(context);

  double get buttonHeight => context.appTheme.dimensions.buttonHeight(context);

  double get cardPadding => context.appTheme.dimensions.cardPadding(context);

  double get cardRadius => context.appTheme.dimensions.cardRadius(context);

  double get chipHeight => context.appTheme.dimensions.chipHeight(context);

  double get dividerThickness => context.appTheme.dimensions.dividerThickness(context);

  double get doctorCardHeight => context.appTheme.dimensions.doctorCardHeight(context);

  double get icon => context.appTheme.dimensions.icon(context);

  double get imageHeight => context.appTheme.dimensions.imageHeight(context);

  double get imageWidth => context.appTheme.dimensions.imageWidth(context);

  double get inputHeight => context.appTheme.dimensions.inputHeight(context);

  double get navBarHeight => context.appTheme.dimensions.navBarHeight(context);

  double get queueNumberSize => context.appTheme.dimensions.queueNumberSize(context);

  double get statusBarHeight => context.appTheme.dimensions.statusBarHeight(context);

}

class ElevationExtension {
  final BuildContext context;

  ElevationExtension(this.context);

  double get card => context.appTheme.elevations.card(context);

  double get dialog => context.appTheme.elevations.dialog(context);

  double get level1 => context.appTheme.elevations.level1(context);

  double get level2 => context.appTheme.elevations.level2(context);

  double get level3 => context.appTheme.elevations.level3(context);

  double get popover => context.appTheme.elevations.popover(context);

  double get surface => context.appTheme.elevations.surface(context);

}
