import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';
import '../theme/app_theme_extension.dart';

class TypographyTokens {
  const TypographyTokens();

  TextStyle title(context) {
    final appTheme = Theme.of(context).extension<AppThemeExtension>()!;
    final size = ResponsiveValue<double>(
      mobile: 24,
      tablet: 28,
      desktop: 36,
    ).resolve(context);

    return TextStyle(
      fontSize: size.sp,
      fontWeight: FontWeight.w700,
      color: appTheme.colors.textPrimary,
    );
  }

  TextStyle body(context) {
    final size = ResponsiveValue<double>(
      mobile: 14,
      tablet: 16,
      desktop: 18,
    ).resolve(context);

    return TextStyle(
      fontSize: size.sp,
    );
  }
}
