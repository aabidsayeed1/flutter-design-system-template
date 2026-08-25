import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';
import '../theme/app_theme_extension.dart';

class GeneratedTypographyTokens {
  const GeneratedTypographyTokens();

  TextStyle display(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 32,
      tablet: 40,
      desktop: 48,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 40,
      tablet: 48,
      desktop: 56,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textPrimary,
      height: lineHeight / fontSize,
      letterSpacing: -0.5.sp,
    );
  }

  TextStyle h1(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 28,
      tablet: 32,
      desktop: 40,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 36,
      tablet: 40,
      desktop: 48,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textPrimary,
      height: lineHeight / fontSize,
    );
  }

  TextStyle h2(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 22,
      tablet: 24,
      desktop: 30,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 28,
      tablet: 32,
      desktop: 38,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textPrimary,
      height: lineHeight / fontSize,
    );
  }

  TextStyle h3(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 18,
      tablet: 20,
      desktop: 24,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 24,
      tablet: 28,
      desktop: 32,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textPrimary,
      height: lineHeight / fontSize,
    );
  }

  TextStyle subtitle(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 16,
      tablet: 18,
      desktop: 20,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 22,
      tablet: 24,
      desktop: 28,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textPrimary,
      height: lineHeight / fontSize,
    );
  }

  TextStyle bodyLarge(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 16,
      tablet: 18,
      desktop: 20,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 24,
      tablet: 28,
      desktop: 30,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textSecondary,
      height: lineHeight / fontSize,
    );
  }

  TextStyle body(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 14,
      tablet: 16,
      desktop: 18,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 22,
      tablet: 24,
      desktop: 28,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textSecondary,
      height: lineHeight / fontSize,
    );
  }

  TextStyle bodySmall(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 12,
      tablet: 13,
      desktop: 14,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 18,
      tablet: 20,
      desktop: 22,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textSecondary,
      height: lineHeight / fontSize,
    );
  }

  TextStyle caption(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 11,
      tablet: 12,
      desktop: 13,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 16,
      tablet: 18,
      desktop: 20,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textTertiary,
      height: lineHeight / fontSize,
    );
  }

  TextStyle overline(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 10,
      tablet: 11,
      desktop: 12,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 14,
      tablet: 16,
      desktop: 18,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textTertiary,
      height: lineHeight / fontSize,
      letterSpacing: 1.2.sp,
    );
  }

  TextStyle button(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 14,
      tablet: 15,
      desktop: 16,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 20,
      tablet: 22,
      desktop: 24,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textOnPrimary,
      height: lineHeight / fontSize,
      letterSpacing: 0.3.sp,
    );
  }

  TextStyle label(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 13,
      tablet: 14,
      desktop: 15,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 18,
      tablet: 20,
      desktop: 22,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textPrimary,
      height: lineHeight / fontSize,
    );
  }

  TextStyle number(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 28,
      tablet: 32,
      desktop: 40,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 34,
      tablet: 38,
      desktop: 48,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textPrimary,
      height: lineHeight / fontSize,
    );
  }

  TextStyle numberSmall(context) {
    final fontSize = ResponsiveValue<double>(
      mobile: 20,
      tablet: 22,
      desktop: 26,
    ).resolve(context).sp;
    final lineHeight = ResponsiveValue<double>(
      mobile: 26,
      tablet: 28,
      desktop: 32,
    ).resolve(context).sp;

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textPrimary,
      height: lineHeight / fontSize,
    );
  }


}
