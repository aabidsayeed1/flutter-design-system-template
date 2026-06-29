import '../generated/generated_dimension_tokens.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class DimensionTokens extends GeneratedDimensionTokens {
  const DimensionTokens();
  double buttonHeight(context) {
    return ResponsiveValue<double>(
      mobile: 48,
      tablet: 52,
      desktop: 56,
    ).resolve(context).h;
  }

  double icon(context) {
    return ResponsiveValue<double>(
      mobile: 20,
      tablet: 24,
      desktop: 28,
    ).resolve(context).r;
  }

  double avatar(context) {
    return ResponsiveValue<double>(
      mobile: 40,
      tablet: 48,
      desktop: 56,
    ).resolve(context).r;
  }

  double imageWidth(context) {
    return ResponsiveValue<double>(
      mobile: 100,
      tablet: 120,
      desktop: 160,
    ).resolve(context).w;
  }

  double imageHeight(context) {
    return ResponsiveValue<double>(
      mobile: 80,
      tablet: 100,
      desktop: 140,
    ).resolve(context).h;
  }
}
