import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class GeneratedSpacingTokens {
  const GeneratedSpacingTokens();

  double xs(context) {
    return ResponsiveValue<double>(
      mobile: 4,
      tablet: 6,
      desktop: 8,
    ).resolve(context).r;
  }

  double sm(context) {
    return ResponsiveValue<double>(
      mobile: 8,
      tablet: 10,
      desktop: 14,
    ).resolve(context).r;
  }

  double md(context) {
    return ResponsiveValue<double>(
      mobile: 12,
      tablet: 16,
      desktop: 20,
    ).resolve(context).r;
  }

  double lg(context) {
    return ResponsiveValue<double>(
      mobile: 24,
      tablet: 28,
      desktop: 36,
    ).resolve(context).r;
  }

  double xl(context) {
    return ResponsiveValue<double>(
      mobile: 32,
      tablet: 36,
      desktop: 44,
    ).resolve(context).r;
  }

  double x2xl(context) {
    return ResponsiveValue<double>(
      mobile: 40,
      tablet: 48,
      desktop: 56,
    ).resolve(context).r;
  }


}
