import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class SpacingTokens {
  const SpacingTokens();

  double sm(context) {
    return ResponsiveValue<double>(
      mobile: 6,
      tablet: 8,
      desktop: 12,
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
      mobile: 20,
      tablet: 24,
      desktop: 32,
    ).resolve(context).r;
  }
}
