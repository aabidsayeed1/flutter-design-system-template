import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class GeneratedRadiusTokens {
  const GeneratedRadiusTokens();

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
      desktop: 12,
    ).resolve(context).r;
  }

  double md(context) {
    return ResponsiveValue<double>(
      mobile: 12,
      tablet: 14,
      desktop: 18,
    ).resolve(context).r;
  }

  double lg(context) {
    return ResponsiveValue<double>(
      mobile: 16,
      tablet: 18,
      desktop: 22,
    ).resolve(context).r;
  }

  double xl(context) {
    return ResponsiveValue<double>(
      mobile: 20,
      tablet: 24,
      desktop: 28,
    ).resolve(context).r;
  }

  double full(context) {
    return ResponsiveValue<double>(
      mobile: 100,
      tablet: 100,
      desktop: 100,
    ).resolve(context).r;
  }


}
